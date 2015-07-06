package com.babylonhxext.loaders.ply;

import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import haxe.io.Input;

/**
 * ...
 * @author Krtolica Vujadin
 */
 
// taken from https://gist.github.com/KeyMaster-/247fee525cf73d086dc3

typedef Element = {
	var name:String;
	var count:Int; //Number of lines specifying data of this element
	var orderedPropNames:Array<String>; //The names of the properties as they appear in the file
	var propertyTypes:StringMap<PlyType>; //What type of data the element properties are
}
 
typedef ListData = {
	var count:Int; //Number of data elements
	var data:Array<Dynamic>;
}
 
//Specifies what Haxe data type the PLY type should be parsed to
enum PlyType {
	float;
	int;
	list(valueType:PlyType); //List also specifies the type of data of the elements of the list
}

class PlyParser {
	
	var i:Input;
	
	//All the elements in the file
	public var elements:StringMap<Element>;
	
	//List of element names as they are listed in the file
	public var orderedElementNames:Array<String>;
	
	public var data:ObjectMap<Element, Array<Dynamic>>;
	
	public function new(input:Input) {
		i = input;
		i.bigEndian = true;
	}
	
	public function read():Void {
		elements = new StringMap<Element>();
		orderedElementNames = new Array<String>();
		data = new ObjectMap<Element, Array<Dynamic>>();
		
		var fileString:String = i.readAll().toString();
		var lines:Array<String> = fileString.split('\n');
		parse(lines);
	}
	
	function parse(lines:Array<String>):Void {
		var headerEnd:Int = lines.indexOf("end_header");
		if (headerEnd != -1) {
			parseHeader(lines.slice(0, headerEnd));
		}
		else {
			throw "\'end_header\' could not be found!";
		}
		
		parseData(lines.slice(headerEnd + 1));		
	}
	
	/**
	 * Fills the 'elements' array with parsed element data
	 * @param	lines	An array of lines making up the header
	 */
	function parseHeader(lines:Array<String>):Void {
		var lineParts:Array<String>;
		var type:String;
		
		var curElement:Element = {
			name:"",
			count:0,
			orderedPropNames:null,
			propertyTypes:null
		}
		
		for (line in lines) {
			line = StringTools.trim(line);
			lineParts = line.split(' ');
			
			type = lineParts[0];
			switch(type) {
				case "element":
					curElement = {
						name:lineParts[1],
						count:Std.parseInt(lineParts[2]),
						orderedPropNames:new Array<String>(),
						propertyTypes:new StringMap<PlyType>()
					};
					elements.set(curElement.name, curElement);
					orderedElementNames.push(curElement.name);
					
				case "property":
					//Type is scalar (any variation of ints, chars, floats)
					if (isScalarType(lineParts[1])) {
						curElement.propertyTypes.set(lineParts[2], parseScalarType(lineParts[1]));
						curElement.orderedPropNames.push(lineParts[2]);
					}
					//Type is list, handle specifically
					else {
						curElement.propertyTypes.set(lineParts[4], PlyType.list(parseScalarType(lineParts[3])));
						curElement.orderedPropNames.push(lineParts[4]);
					}
			}
			
		}
	}
	/**
	 * Parses the data in the file according to the elements parsed beforehands
	 * @param	lines	An array of lines making up the data
	 */
	function parseData(lines:Array<String>):Void {
		var elementLines:Array<String>;
		var startLinePos:Int = 0;
		var element:Element;
		for (elementName in orderedElementNames) {
			element = elements.get(elementName);
			parseElementData(element, lines.slice(startLinePos, startLinePos + element.count));
			startLinePos += element.count;
		}
	}
	
	/**
	 * Parses all the data of one element
	 * @param	element		The element the data belongs to
	 * @param	lines		An array of lines containing all the data belonging to this element
	 */
	function parseElementData(element:Element, lines:Array<String>):Void {
		var elementData:Array<Dynamic> = new Array<Dynamic>();
		data.set(element, elementData);
		
		var valueIndex:Int = 0;
		var lineParts:Array<String>;
		for (line in lines) {
			lineParts = line.split(' ');
			
			var dataSet = { };
			valueIndex = 0;
			var type:PlyType;
			for (propertyName in element.orderedPropNames) {
				type = element.propertyTypes.get(propertyName);
				switch(type) {
					case PlyType.list(valueType):
						var listData:ListData = {
							count:Std.parseInt(lineParts[valueIndex]),
							data:new Array<Dynamic>()
						};
						valueIndex++;
						switch(valueType) {
							case PlyType.int:
								for (n in valueIndex...valueIndex + listData.count) listData.data.push(Std.parseInt(lineParts[n]));
								
							case PlyType.float:
								for (n in valueIndex...valueIndex + listData.count) listData.data.push(Std.parseFloat(lineParts[n]));
								
							case PlyType.list:
								throw "The value type of a list seems to be another list. This is not handled";
						}
						valueIndex += listData.count;
						Reflect.setField(dataSet, propertyName, listData);
						
					case PlyType.int:
						Reflect.setField(dataSet, propertyName, Std.parseInt(lineParts[valueIndex]));
						valueIndex++;
						
					case PlyType.float:
						Reflect.setField(dataSet, propertyName, Std.parseFloat(lineParts[valueIndex]));
						valueIndex++;
				}
			}
			elementData.push(dataSet);
		}
	}
	
	function isScalarType(s:String):Bool {
		switch(s) {
			case "int", "uint", "int8", "uint8", "int16", "int32", "uint32", 
				 "char", "uchar", "short", "ushort",
				 "float", "float32", "float64", "double" :
				return true;
				
			case "list":
				return false;
		}
		throw "Type " + s + " not recognized";
	}
	
	function parseScalarType(s:String):PlyType {
		var t:PlyType = PlyType.float;
		switch(s) {
			case "int", "uint", "int8", "uint8", "int16", "int32", "uint32", 
				 "char", "uchar", "short", "ushort" :
				t = PlyType.int;
				
			case "float", "float32", "float64", "double":
				t =  PlyType.float;
		}
		return t;
	}
	
}
 