/**
 * @fileOverview
 * Ludei's plugins are multiplatform Javascript APIs, that work in any of the three environments 
 * of CocoonJS: accelerated Canvas+, webview+ and system webview.
 * - Select the specific plugin below to open the relevant documentation section.
 <ul>
    <li><a href="Cocoon.html">Cocoon</a></li>
    <li><a href="Cocoon.Ad.html">Ad</a></li>
    <li><a href="Cocoon.App.html">App</a></li>
    <li><a href="Cocoon.Camera.html">Camera</a></li>
    <li><a href="Cocoon.Device.html">Device</a></li>
    <li><a href="Cocoon.Dialog.html">Dialog</a></li>
    <li><a href="Cocoon.Motion.html">Motion</a></li>
    <li><a href="Cocoon.Multiplayer.html">Multiplayer</a></li>
    <li><a href="Cocoon.Notification.html">Notification</a></li>
    <li><a href="Cocoon.Proxify.html">Proxify</a></li>
    <li><a href="Cocoon.Social.html">Social</a></li>
    <li><a href="Cocoon.Store.html">Store</a></li>
    <li><a href="Cocoon.Touch.html">Touch</a></li>
    <li><a href="Cocoon.Utils.html">Utils</a></li>
    <li><a href="Cocoon.WebView.html">WebView</a></li>
    <li><a href="Cocoon.Widget.html">Widget</a></li>
</ul>
 <br/>The CocoonJS Plugin's library (cocoon.js and cocoon.min.js) can be found at Github. <br/>
 <a href="https://github.com/ludei/CocoonJS-Plugins"><img src="img/download.png" style="width:230px;height:51px;" /></a>
 <br/><br/>In addition to all the previously mentioned, in the following link you'll find an <a href="http://support.ludei.com/hc/en-us/articles/201821276-Extensions-overview">overview of all the avaliable features</a> in which each plugin support and availability are detailed.
 <br/><br/>
 * We hope you find everything you need to get going here, but if you stumble on any problems with the docs or the plugins, 
 * just drop us a line at our forum (support.ludei.com) and we'll do our best to help you out.
 * <h3>Tools</h3>
 <a href="http://support.ludei.com/hc/communities/public/topics"><img src="img/cocoon-tools-1.png" /></a>
 <a href="http://support.ludei.com/hc"><img src="img/cocoon-tools-2.png" /></a>
 <a href="https://cloud.ludei.com/"><img src="img/cocoon-tools-3.png" /></a>
 <a href="https://www.ludei.com/cocoonjs/how-to-use/"><img src="img/cocoon-tools-4.png" /></a>
 * @version 3.0.4
 */
(function () {
    
    /**
    * The "Cocoon" object holds all the CocoonJS Extensions and other stuff needed for the CocoonJS environment.
    * @namespace Cocoon
    */
    Cocoon = window.Cocoon ? window.Cocoon : {};
    
    /**
     * @property {string} version Current version of the CocoonJS Extensions.
     * @memberOf Cocoon
     * @example
     * console.log(Cocoon.version);
     */
    Cocoon.version = "3.0.4";
    
    /**
     * Is the native environment available? true if so.
     * @property {bool} version
     * @memberof Cocoon
     * @private
     * @example
     * if(Cocoon.nativeAvailable) { ... do native stuff here ... }
     */

    Cocoon.nativeAvailable = (!!window.ext);

    /**
    * This utility function allows to create an object oriented like hierarchy between two functions using their prototypes.
    * This function adds a "superclass" and a "__super" attributes to the subclass and it's functions to reference the super class.
    * @memberof Cocoon
    * @private
    * @static
    * @param {function} subc The subclass function.
    * @param {function} superc The superclass function.
    */
    Cocoon.extend = function(subc, superc) {
        var subcp = subc.prototype;

        var CocoonJSExtendHierarchyChainClass = function() {};
        CocoonJSExtendHierarchyChainClass.prototype = superc.prototype;

        subc.prototype = new CocoonJSExtendHierarchyChainClass();
        subc.superclass = superc.prototype;
        subc.prototype.constructor = subc;

        if (superc.prototype.constructor === Object.prototype.constructor) {
            superc.prototype.constructor = superc;
        }

        for (var method in subcp) {
            if (subcp.hasOwnProperty(method)) {
                subc.prototype[method] = subcp[method];
            }
        }
    }

    /**
    * This utility function copies the properties from one object to a new object array, the result object array can be used as arguments when calling Cocoon.callNative()
    * @memberof Cocoon
    * @static
    * @private
    * @param {function} obj The base object that contains all properties defined.
    * @param {function} copy The object that user has defined.
    */
    Cocoon.clone = function(obj,copy){
        if (null == obj || "object" != typeof obj) return obj;
        var arr = [];
        for (var attr in obj) {
            if ( copy.hasOwnProperty(attr) ) { 
                arr.push(copy[attr]);
            }else{
                arr.push(obj[attr]);
            }
        }
        return arr;
    }

    /**
    * IMPORTANT: This function should only be used by Ludei.
    * This function allows a call to the native extension object function reusing the same arguments object.
    * Why is interesting to use this function instead of calling the native object's function directly?
    * As the Cocoon object functions expicitly receive parameters, if they are not present and the native call is direcly mapped,
    * undefined arguments are passed to the native side. Some native functions do not check the parameters validation
    * correctly (just check the number of parameters passed).
    * Another solution instead of using this function call is to correctly check if the parameters are valid (not undefined) to make the
    * call, but it takes more work than using this approach.
    * @static
    * @private
    * @param {string} nativeExtensionObjectName The name of the native extension object name. The object that is a member of the 'ext' object.
    * @param {string} nativeFunctionName The name of the function to be called inside the native extension object.
    * @param {object} arguments The arguments object of the Cocoon extension object function. It contains all the arguments passed to the Cocoon extension object function and these are the ones that will be passed to the native call too.
    * @param {boolean} [async] A flag to indicate if the makeCall (false or undefined) or the makeCallAsync function should be used to perform the native call.
    * @returns Whatever the native function call returns.
    */
    Cocoon.callNative = function(nativeExtensionObjectName, nativeFunctionName, args, async) {
        if (Cocoon.nativeAvailable) {
            var argumentsArray = Array.prototype.slice.call(args);
            argumentsArray.unshift(nativeFunctionName);
            var nativeExtensionObject = ext[nativeExtensionObjectName];
            var makeCallFunction = async ? nativeExtensionObject.makeCallAsync : nativeExtensionObject.makeCall;
            var ret = makeCallFunction.apply(nativeExtensionObject, argumentsArray);
            var finalRet = ret;
            if (typeof ret === "string") {
                try {
                    finalRet = JSON.parse(ret);
                }
                catch(error) {
                    console.log(error);
                }
            }
            return finalRet;
        }
    };

    /**
    * Returns an object retrieved from a path specified by a dot specified text path starting from a given base object.
    * It could be useful to find the reference of an object from a defined base object. For example the base object could be window and the
    * path could be "Cocoon.App" or "document.body".
    * @static
    * @param {Object} baseObject The object to start from to find the object using the given text path.
    * @param {string} objectPath The path in the form of a text using the dot notation. i.e. "document.body"
    * @private
    * @memberof Cocoon
    * For example:
    * var body = Cocoon.getObjectFromPath(window, "document.body");
    */
    Cocoon.getObjectFromPath = function(baseObject, objectPath) {
        var parts = objectPath.split('.');
        var obj = baseObject;
        for (var i = 0, len = parts.length; i < len; ++i) 
        {
            obj[parts[i]] = obj[parts[i]] || undefined;
            obj = obj[parts[i]];
        }
        return obj;
    };

    /**
    * A class that represents objects to handle events. Event handlers have always the same structure:
    * Mainly they provide the addEventListener and removeEventListener functions.
    * Both functions receive a callback function that will be added or removed. All the added callback
    * functions will be called when the event takes place.
    * Additionally they also allow the addEventListenerOnce and notifyEventListeners functions.
    * @constructor
    * @param {string} nativeExtensionObjectName The name of the native extension object (inside the ext object) to be used.
    * @param {string} CocoonExtensionObjectName The name of the sugarized extension object.
    * @param {string} nativeEventName The name of the native event inside the ext object.
    * @param {number} [chainFunction] An optional function used to preprocess the listener callbacks. This function, if provided,
    * will be called before any of the other listeners.
    * @memberof Cocoon
    * @private
    * @static
    */
    Cocoon.EventHandler = function(nativeExtensionObjectName, CocoonExtensionObjectName, nativeEventName, chainFunction) {
        this.listeners = [];
        this.listenersOnce = [];
        this.chainFunction = chainFunction;

        /**
        * Adds a callback function so it can be called when the event takes place.
        * @param {function} listener The callback function to be added to the event handler object. See the referenced Listener function documentation for more detail in each event handler object's documentation.
        * @memberof Cocoon.EventHandler
        * @private
        * @static
        */
        this.addEventListener = function(listener) {
            if (chainFunction) {
                var f = function() {
                    chainFunction.call(this, arguments.callee.sourceListener, Array.prototype.slice.call(arguments)); 
                };
                listener.CocoonEventHandlerChainFunction = f;
                f.sourceListener = listener;
                listener = f;
            }

            var CocoonExtensionObject = Cocoon.getObjectFromPath(Cocoon, CocoonExtensionObjectName);
            if (CocoonExtensionObject && CocoonExtensionObject.nativeAvailable) {
                ext[nativeExtensionObjectName].addEventListener(nativeEventName, listener);
            }
            else {
                var indexOfListener = this.listeners.indexOf(listener);
                if (indexOfListener < 0) {
                    this.listeners.push(listener);
                }
            }
        };
        /**
        * Adds a callback function that will be called only one time.
        * @param {function} listener The callback function to be added to the event handler object. See the referenced Listener function documentation for more detail in each event handler object's documentation.
        * @memberof Cocoon.EventHandler
        * @private
        * @static
        */

        this.addEventListenerOnce = function(listener)
        {
            if (chainFunction) {
                var f = function() { chainFunction(arguments.callee.sourceListener,Array.prototype.slice.call(arguments)); };
                f.sourceListener = listener;
                listener = f;
            }

            var CocoonExtensionObject = Cocoon.getObjectFromPath(Cocoon, CocoonExtensionObjectName);
            if (CocoonExtensionObject.nativeAvailable) {
                ext[nativeExtensionObjectName].addEventListenerOnce(nativeEventName, listener);
            }
            else
            {
                var indexOfListener = this.listeners.indexOf(listener);
                if (indexOfListener < 0)
                {
                    this.listenersOnce.push(listener);
                }
            }
        };

        /**
        * Removes a callback function that was added to the event handler so it won't be called when the event takes place.
        * @param {function} listener The callback function to be removed from the event handler object. See the referenced Listener function documentation for more detail in each event handler object's documentation.
        * @memberof Cocoon.EventHandler
        * @private
        * @static
        */
        this.removeEventListener = function (listener) {

            if (chainFunction) {
                listener = listener.CocoonEventHandlerChainFunction;
                delete listener.CocoonEventHandlerChainFunction;
            }

            var CocoonExtensionObject = Cocoon.getObjectFromPath(Cocoon, CocoonExtensionObjectName);
            if (CocoonExtensionObject.nativeAvailable) {
                ext[nativeExtensionObjectName].removeEventListener(nativeEventName, listener);
            }
            else {
                var indexOfListener = this.listeners.indexOf(listener);
                if (indexOfListener >= 0) {
                    this.listeners.splice(indexOfListener, 1);
                }
            }
        };

        this.removeEventListenerOnce = function (listener) {

            if (chainFunction) {
                listener = listener.CocoonEventHandlerChainFunction;
                delete listener.CocoonEventHandlerChainFunction;
            }

            var CocoonExtensionObject = Cocoon.getObjectFromPath(Cocoon, CocoonExtensionObjectName);
            if (CocoonExtensionObject.nativeAvailable) {
                ext[nativeExtensionObjectName].removeEventListenerOnce(nativeEventName, listener);
            }
            else {
                var indexOfListener = this.listenersOnce.indexOf(listener);
                if (indexOfListener >= 0) {
                    this.listenersOnce.splice(indexOfListener, 1);
                }
            }
        };

        /**
        * @memberof Cocoon.EventHandler
        * @private
        * @static
        */

        this.notifyEventListeners = function() {
            var CocoonExtensionObject = Cocoon.getObjectFromPath(Cocoon, CocoonExtensionObjectName);
            if (CocoonExtensionObject && CocoonExtensionObject.nativeAvailable) {
                ext[nativeExtensionObjectName].notifyEventListeners(nativeEventName);
            } else {

                var argumentsArray= Array.prototype.slice.call(arguments);
                var listeners =     Array.prototype.slice.call(this.listeners);
                var listenersOnce = Array.prototype.slice.call(this.listenersOnce);
                var _this = this;
                // Notify listeners after a while ;) === do not block this thread.
                setTimeout(function() {
                    for (var i = 0; i < listeners.length; i++) {
                        listeners[i].apply(_this, argumentsArray);
                    }
                    for (var i = 0; i < listenersOnce.length; i++) {
                        listenersOnce[i].apply(_this, argumentsArray);
                    }
                }, 0);

                _this.listenersOnce= [];
            }
        };
        return this;
    };
    
    /**
    * This function is used to create extensions in the global namespace of the "Cocoon" object.
    * @memberof Cocoon
    * @private
    * @static
    * @param {string} namespace The extensions namespace, ex: Cocoon.App.Settings.
    * @param {object} callback The callback which holds the declaration of the new extension.
    * @example
    * Cocoon.define("Cocoon.namespace" , function(extension){
    * "use strict";
    *
    * return extension;
    * });
    */
    Cocoon.define = function(extName, ext){
        
        var namespace = (extName.substring(0,7) == "Cocoon.") ? extName.substr(7) : extName;

        var base    = window.Cocoon;
        var parts  = namespace.split(".");
        var object = base;
    
        for(var i = 0; i < parts.length; i++) {
            var part = parts[i];
            (!object[part]) ? console.log("Created namespace: " + extName) : console.log("Updated namespace: - " + extName);
            object = object[part] = (i == (parts.length - 1)) ? ext( (object[part] || {}) ) : {};
            if(!object) {
                throw "Unable to create class " + extName;
            }
        }
                
        return true;
    }

    console.log("Created namespace: Cocoon");

})();;Cocoon.define("Cocoon.Signal" , function(extension){
    "use strict";

    /**
    * This namespace is used to create an Event Emitter/Dispatcher that works together.
    * with the Cocoon.EventHandler.
    * @namespace Cocoon.Signal
    * @private
    */

    /**
    * This constructor creates a new Signal that holds and emits different events that are specified inside each extension.
    * @memberof Cocoon.Signal
    * @private
    * @constructs createSignal
    */
    extension.createSignal = function(){
        /** @lends Cocoon.Signal.prototype */
    	this.handle = null;
    	this.signals = {};
    	
        /**
        * Registers a new Signal.
        * @param {string} namespace The name of the signal which will be emitted.
        * @param {object} handle The Cocoon.EventHandler that will handle the signals.
        * @function register
        * @private
        * @example
        * signal.register("banner.ready", new Cocoon.EventHandler);
        */
    	this.register = function(namespace, handle){

            if( (!namespace) && (!handle)) throw new Error("Can't create signal " + (namespace || ""));

            if(handle.addEventListener){
                this.signals[namespace] = handle;
                return true;
            }

            if(!handle.addEventListener){
                this.signals[namespace] = {};
                for (var prop in handle) {
                    if(handle.hasOwnProperty(prop)){
                        this.signals[namespace][prop] = handle[prop];
                    }
                };
                return true;
            }
            
            throw new Error("Can't create handler for " + namespace + " signal.");
            return false;
    	},

        /**
        * Exposes the already defined signals, and can be use to atach a callback to a Cocoon.EventHandler event.
        * @param {string} signal The name of the signal which will be emitted.
        * @param {object} callback The Cocoon.EventHandler that will handle the signals.
        * @param {object} params Optional parameters, example { once : true }
        * @function expose
        * @private
        * @example
        * Cocoon.namespace.on("event",function(){});
        */
    	this.expose = function(){
    		return function(signal, callback, params){
                var once = false;

                if(arguments.length === 1){
                    var that = this;
                    var fnc = function(signal){
                        this.signal = signal;
                    }
                    
                    fnc.prototype.remove = function(functionListener){
                        var handle = that.signals[this.signal];
                        if(handle && handle.removeEventListener) {
                            handle.removeEventListener.apply(that,[functionListener]);
                            that.signals[this.signal] = undefined;
                        }
                    }
                    return new fnc(signal);
                }

                if((params) && (params.once)){
                    once = true;
                }

                if(!this.signals[signal]) throw new Error("The signal " + signal + " does not exists.");
                var handle = this.signals[signal];
                if(handle.addEventListener){
                    if(once){
                        handle.addEventListenerOnce(function(){
                            callback.apply( this || window , arguments);
                        });
                    }else{
                        handle.addEventListener(function(){
                            callback.apply( this || window , arguments);
                        });
                    }
                }

                if(!this.signals[signal].addEventListener){
                    for (var prop in this.signals[signal]) {
                        
                        if(!this.signals[signal].hasOwnProperty(prop)) continue;
                        
                        var handle = this.signals[signal][prop];

                        if(once){
                            handle.addEventListenerOnce(function(){
                                this.clbk[this.name].apply( this || window , arguments);
                            }.bind({ name : prop , clbk : callback }));
                        }else{
                            handle.addEventListener(function(){
                                this.clbk[this.name].apply( this || window , arguments);
                            }.bind({ name : prop , clbk : callback }));
                        }
                        
                    }
                }

    		}.bind(this);
    	}
    }

    return extension;

});;/**
 * This namespace represents different methods to control your application.
 *
 * <div class="alert alert-success">
 * <p>Here you will find demos about this namespace: </p> 
 * <ul> <li> <a href="https://github.com/ludei/cocoonjs-demos/tree/master/Rate">Rate demo</a>.</li>
 * <li> <a href="https://github.com/ludei/cocoonjs-demos/tree/Sound">Sound demo</a>.</li>
 * <li> <a href="https://github.com/ludei/cocoonjs-demos/tree/Vibration">Vibration demo</a>.</li>
 * <li> <a href="https://github.com/ludei/cocoonjs-demos/tree/master/Basic%20examples">Basic examples demo</a>.</li></ul>
 * </div>
 *
 * @namespace Cocoon.App
 * @example
 * // Example 1: Closes the application
 * Cocoon.App.exit();
 * // Example 2: Opens a given URL
 * Cocoon.App.openURL("http://www.ludei.com");
 * // Example 3: Fired when the application is suspended
 * Cocoon.App.on("suspended", function(){
 *  ...
 * });
 */
Cocoon.define("Cocoon.App" , function(extension){
    
    extension.nativeAvailable = (!!window.ext) && (!!window.ext.IDTK_APP);

    extension.isBridgeAvailable = function(){
        if (Cocoon.App.forward.nativeAvailable === 'boolean') {
            return Cocoon.App.forward.nativeAvailable;
        }
        else {
            var available = Cocoon.callNative("IDTK_APP", "forwardAvailable", arguments);
            available = !!available;
            Cocoon.App.forward.nativeAvailable = available;
            return available;
        }
    };

    /**
     * Makes a forward call of some javascript code to be executed in a different environment (i.e. from CocoonJS to the WebView and viceversa).
     * It waits until the code is executed and the result of it is returned === synchronous.
     * @function forward
     * @memberof Cocoon.App
     * @param {string} code Some JavaScript code in a string to be forwarded and executed in a different JavaScript environment (i.e. from CocoonJS to the WebView and viceversa).
     * @return {string} The result of the execution of the passed JavaScript code in the different JavaScript environment.
     * @example
     * Cocoon.App.forward("alert('Ludei!');");
     */
    extension.forward = function (javaScriptCode) {
        if (Cocoon.App.nativeAvailable && Cocoon.App.isBridgeAvailable()) {
            return Cocoon.callNative("IDTK_APP", "forward", arguments);
        }
        else if (!navigator.isCocoonJS) {
            if (window.name == 'CocoonJS_App_ForCocoonJS_WebViewIFrame') {
                return window.parent.eval(javaScriptCode);
            }
            else {
                return window.frames['CocoonJS_App_ForCocoonJS_WebViewIFrame'].window.eval(javaScriptCode);
            }
        }
    };

    /**
     * Makes a forward call of some javascript code to be executed in a different environment (i.e. from CocoonJS to the WebView and viceversa).
     * It is asyncrhonous so it does not wait until the code is executed and the result of it is returned. Instead, it calls a callback function when the execution has finished to pass the result.
     * @function forwardAsync
     * @memberof Cocoon.App
     * @param {string} javaScriptCode Some JavaScript code in a string to be forwarded and executed in a different JavaScript environment (i.e. from CocoonJS to the WebView and viceversa).
     * @param {function} [callback] A function callback (optional) that will be called when the passed JavaScript code is executed in a different thread to pass the result of the execution in the different JavaScript environment.
     * @example
     * Cocoon.App.forwardAsync("alert('Ludei!');", function(){
     * ...
     * });
     */
    extension.forwardAsync = function (javaScriptCode, returnCallback) {
        if (Cocoon.App.nativeAvailable && Cocoon.App.isBridgeAvailable()) {
            if (typeof returnCallback !== 'undefined') {
                return ext.IDTK_APP.makeCallAsync("forward", javaScriptCode, returnCallback);
            }
            else {
                return ext.IDTK_APP.makeCallAsync("forward", javaScriptCode);
            }
        }
        else {
            setTimeout(function() {
                var res;
                window.name == 'CocoonJS_App_ForCocoonJS_WebViewIFrame' ? 
                    (res = window.parent.eval(javaScriptCode), (typeof returnCallback === 'function') && returnCallback(res) ) :
                    (
                        res = window.parent.frames['CocoonJS_App_ForCocoonJS_WebViewIFrame'].window.eval(javaScriptCode), 
                        (typeof returnCallback === 'function') && returnCallback(res)
                    );
            }, 1);
        }
    };

    /**
     * Allows to load a new JavaScript/HTML5 resource that can be loaded either locally (inside the platform/device storage) or using a remote URL.
     * @function load
     * @memberof Cocoon.App
     * @param {string} path A path to a resource stored in the platform or in a URL to a remote resource.
     * @param {Cocoon.App.StorageType} [storageType] If the path argument represents a locally stored resource, the developer can specify the storage where it is stored. If no value is passes, the {@link Cocoon.App.StorageType.APP_STORAGE} value is used by default.
     * @example
     * Cocoon.App.load("index.html");
     */
    extension.load = function (path, storageType) {
        if (Cocoon.App.nativeAvailable) {
            return Cocoon.callNative("IDTK_APP", "loadPath", arguments);
        }
        else if (!navigator.isCocoonJS) {
            var xhr = new XMLHttpRequest();

            xhr.onreadystatechange = function (event) {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        var jsCode;
                        // If there is no webview, it means we are in the webview, so notify the CocoonJS environment
                        if (!Cocoon.App.EmulatedWebViewIFrame) {
                            jsCode = "window.Cocoon && window.Cocoon.App.onLoadInTheWebViewSucceed.notifyEventListeners('" + path + "');";
                        }
                        // If there is a webview, it means we are in CocoonJS, so notify the webview environment
                        else {
                            jsCode = "window.Cocoon && window.Cocoon.App.onLoadInCocoonJSSucceed.notifyEventListeners('" + path + "');";
                        }
                        Cocoon.App.forwardAsync(jsCode);
                        window.location.href = path;
                    }
                    else if (xhr.status === 404) {
                        this.onreadystatechange = null;
                        var jsCode;
                        // If there is no webview, it means we are in the webview, so notify the CocoonJS environment
                        if (!Cocoon.App.EmulatedWebViewIFrame) {
                            jsCode = "Cocoon && Cocoon.App.onLoadInTheWebViewFailed.notifyEventListeners('" + path + "');";
                        }
                        // If there is a webview, it means we are in CocoonJS, so notify the webview environment
                        else {
                            jsCode = "Cocoon && Cocoon.App.onLoadInCocoonJSFailed.notifyEventListeners('" + path + "');";
                        }
                        Cocoon.App.forwardAsync(jsCode);
                    }
                }
            };
            xhr.open("GET", path, true);
            xhr.send();
        }
    };

    /**
     * Reloads the last loaded path in the current context.
     * @function reload
     * @memberof Cocoon.App
     * @example
     * Cocoon.App.reload();
     */
    extension.reload = function () {
        if (Cocoon.App.nativeAvailable) {
            return Cocoon.callNative("IDTK_APP", "reload", arguments);
        }
        else if (!navigator.isCocoonJS) {
            if (window.name == 'CocoonJS_App_ForCocoonJS_WebViewIFrame') {
                return window.parent.location.reload();
            }
            else {
                return window.parent.frames['CocoonJS_App_ForCocoonJS_WebViewIFrame'].window.location.reload();
            }
        }
    };

    /**
     * Opens a given URL using a system service that is able to open it. For example, open a HTTP URL using the system WebBrowser.
     * @function openURL
     * @memberof Cocoon.App
     * @param {string} url The URL to be opened by a system service.
     * @example
     * Cocoon.App.openURL("http://www.ludei.com");
     */
    extension.openURL = function (url) {
        if (Cocoon.App.nativeAvailable) {
            return Cocoon.callNative("IDTK_APP", "openURL", arguments, true);
        }
        else if (!navigator.isCocoonJS) {
            window.open(url, '_blank');
        }
    }

    /**
     * Forces the app to finish.
     * @function exit
     * @memberof Cocoon.App
     * @example
     * Cocoon.App.exit();
     */
    extension.exit = function () {
        if (Cocoon.App.nativeAvailable) {
            return Cocoon.callNative("IDTK_APP", "forceToFinish", arguments);
        }
        else if (!navigator.isCocoonJS) {
            window.close();
        }
    }

    /**
     * 
     * @memberof Cocoon.App
     * @name Cocoon.App.StorageType
     * @property {string} Cocoon.App.StorageType - The base object
     * @property {string} Cocoon.App.StorageType.APP_STORAGE The application storage.
     * @property {string} Cocoon.App.StorageType.INTERNAL_STORAGE Internal Storage
     * @property {string} Cocoon.App.StorageType.EXTERNAL_STORAGE External Storage
     * @property {string} Cocoon.App.StorageType.TEMPORARY_STORAGE Temporary Storage
     */
    extension.StorageType = {
        APP_STORAGE:        "APP_STORAGE",
        INTERNAL_STORAGE:   "INTERNAL_STORAGE",
        EXTERNAL_STORAGE:   "EXTERNAL_STORAGE",
        TEMPORARY_STORAGE:  "TEMPORARY_STORAGE"
    };

    extension.onSuspended = new Cocoon.EventHandler("IDTK_APP", "App", "onsuspended");

    extension.onActivated = new Cocoon.EventHandler("IDTK_APP", "App", "onactivated");

    extension.onSuspending = new Cocoon.EventHandler("IDTK_APP", "App", "onsuspending");

    extension.onMemoryWarning = new Cocoon.EventHandler("IDTK_APP", "App", "onmemorywarning");

    var signal = new Cocoon.Signal.createSignal();

    /**
     * Allows to listen to events called when the application is suspended.
     * The callback function does not receive any parameter.
     * @event On application suspended
     * @memberof Cocoon.App
     * @example
     * Cocoon.App.on("suspended", function(){
     *  ...
     * });
     */
    signal.register("suspended", extension.onSuspended);
    /**
     * Allows to listen to events called when the application is activated.
     * The callback function does not receive any parameter.
     * @event On application activated
     * @memberof Cocoon.App
     * @example
     * Cocoon.App.on("activated", function(){
     *  ...
     * });
     */
    signal.register("activated", extension.onActivated);

    /**
     * Allows to listen to events called when the application is suspending.
     * The callback function does not receive any parameter.
     * @event On application suspending
     * @memberof Cocoon.App
     * @example
     * Cocoon.App.on("suspending", function(){
     *  ...
     * });
     */
    signal.register("suspending", extension.onSuspending);

    /**
     * Allows to listen to memory warning notifications from the system
     * It is strongly recommended that you implement this method and free up as much memory as possible by disposing of cached data objects, images on canvases that can be recreated.
     * @event On memory warning
     * @memberof Cocoon.App
     * @example
     * Cocoon.App.on("memorywarning", function(){
     *  ...
     * });
     */
     signal.register("memorywarning", extension.onMemoryWarning);


    extension.on = signal.expose();
    
    return extension;
});;Cocoon.define("Cocoon.App" , function(extension){

    function checkEmulatedWebViewReady() {
        var emulatedWB = Cocoon.App.EmulatedWebView;
        if (emulatedWB) {
            return; //ready
        }

        emulatedWB = document.createElement('div'); 
        emulatedWB.setAttribute('id', 'CocoonJS_App_ForCocoonJS_WebViewDiv'); 
        emulatedWB.style.width = 0; 
        emulatedWB.style.height = 0; 
        emulatedWB.style.position = "absolute"; 
        emulatedWB.style.left = 0; 
        emulatedWB.style.top = 0;
        emulatedWB.style.backgroundColor = 'transparent';
        emulatedWB.style.border = "0px solid #000"; 

        var frame = document.createElement("IFRAME");
        frame.setAttribute('id', 'CocoonJS_App_ForCocoonJS_WebViewIFrame');
        frame.setAttribute('name', 'CocoonJS_App_ForCocoonJS_WebViewIFrame');
        frame.style.width = 0; 
        frame.style.height = 0; 
        frame.frameBorder = 0;
        frame.allowtransparency = true;

        emulatedWB.appendChild(frame);
        Cocoon.App.EmulatedWebView = emulatedWB;
        Cocoon.App.EmulatedWebViewIFrame = frame;

        if(!document.body) {
            document.body = document.createElement("body");
        }
        document.body.appendChild(Cocoon.App.EmulatedWebView);
    }

    /**
     * Pauses the Cocoon JavaScript execution loop.
     * The callback function does not receive any parameter.
     * @function pause
     * @memberOf Cocoon.App
     * @example
     * Cocoon.App.pause();
     */
    extension.pause = function()
    {
        if (Cocoon.App.nativeAvailable)
        {
            return Cocoon.callNative("IDTK_APP", "pause", arguments);
        }
    };
    /**
     * Resumes the Cocoon JavaScript execution loop.
     * @function resume
     * @memberOf Cocoon.App
     * @example
     * Cocoon.App.resume();
     */

    extension.resume = function()
    {
        if (Cocoon.App.nativeAvailable)
        {
            return Cocoon.callNative("IDTK_APP", "resume", arguments);
        }
    };

    /**
    * Loads a resource in the WebView environment from the Cocoon environment.
    * @function loadInTheWebView
    * @memberOf Cocoon.App
    * @param {string} path The path to the resource. It can be a remote URL or a path to a local file.
    * @param {Cocoon.App.StorageType} [storageType] An optional parameter to specify at which storage in the device the file path is stored. By default, APP_STORAGE is used.
    * @example
    * Cocoon.App.WebView.on("load", {
    *   success : function(){
    *     Cocoon.App.showTheWebView();
    *   },
    *   error : function(){
    *     console.log("Cannot show the Webview for some reason :/");
    *     console.log(JSON.stringify(arguments));
    *   }
    * });
    * Cocoon.App.loadInTheWebView("wv.html");
    */
    extension.loadInTheWebView = function(path, storageType)
    {
        if (navigator.isCocoonJS && Cocoon.App.nativeAvailable)
        {
            Cocoon.callNative("IDTK_APP", "loadInTheWebView", arguments)
        }
        else
        {
            var xhr = new XMLHttpRequest();

            xhr.onreadystatechange = function(event) {
                if (xhr.readyState === 4)
                {
                    if ((xhr.status >= 200 && xhr.status <=299) || xhr.status === 0)
                    {

                        checkEmulatedWebViewReady();
                        var callback= function(event){
                            Cocoon.App.onLoadInTheWebViewSucceed.notifyEventListeners(path);
                            Cocoon.App.EmulatedWebViewIFrame.removeEventListener("load", callback);
                        };

                        Cocoon.App.EmulatedWebViewIFrame.addEventListener(
                            "load", 
                            callback
                        );
                        Cocoon.App.EmulatedWebViewIFrame.contentWindow.location.href= path;
                    }
                    else
                    {
                        this.onreadystatechange = null;
                        Cocoon.App.onLoadInTheWebViewFailed.notifyEventListeners(path);
                    }
                }
            };
            xhr.open("GET", path, true);
            xhr.send();
        }
    };

    /**
     * Reloads the last loaded path in the WebView context.
     * @function reloadWebView
     * @memberOf Cocoon.App
     * @example
     * Cocoon.App.reloadWebView();
     */
    extension.reloadWebView = function()
    {
        if (Cocoon.App.nativeAvailable && navigator.isCocoonJS)
        {
            Cocoon.callNative("IDTK_APP", "reloadWebView", arguments);
        }
        else
        {
            checkEmulatedWebViewReady();
            Cocoon.App.EmulatedWebViewIFrame.contentWindow.location.reload();
        }
    };

    /**
    * Shows the webview.
    * @function showTheWebView
    * @memberOf Cocoon.App
    * @param {number}  x The top lef x coordinate of the rectangle where the webview will be shown.
    * @param {number}  y The top lef y coordinate of the rectangle where the webview will be shown.
    * @param {number}  width The width of the rectangle where the webview will be shown.
    * @param {number}  height The height of the rectangle where the webview will be shown.
    * @example
    * Cocoon.App.showTheWebView(0 , 0 , window.innerWidth * window.devicePixelRatio, window.innerHeight * window.devicePixelRatio);
    */
    extension.showTheWebView = function(x, y, width, height)
    {
        if (Cocoon.App.nativeAvailable && navigator.isCocoonJS)
        {
            Cocoon.callNative("IDTK_APP", "showTheWebView", arguments)
        }
        else
        {
            checkEmulatedWebViewReady();
            Cocoon.App.EmulatedWebViewIFrame.style.width = (width ? width/window.devicePixelRatio : window.innerWidth)+'px';
            Cocoon.App.EmulatedWebViewIFrame.style.height = (height ? height/window.devicePixelRatio : window.innerHeight)+'px';
            Cocoon.App.EmulatedWebView.style.left = (x ? x : 0)+'px';
            Cocoon.App.EmulatedWebView.style.top = (y ? y : 0)+'px';
            Cocoon.App.EmulatedWebView.style.width = (width ? width/window.devicePixelRatio : window.innerWidth)+'px';
            Cocoon.App.EmulatedWebView.style.height = (height ? height/window.devicePixelRatio : window.innerHeight)+'px';
            Cocoon.App.EmulatedWebView.style.display = "block";

        }
    };

    /**
    * Hides the webview.
    * @function hideTheWebView
    * @memberOf Cocoon.App
    * @example
    * Cocoon.App.hideTheWebView();
    */
    extension.hideTheWebView = function() {
        if (Cocoon.App.nativeAvailable && navigator.isCocoonJS) {
            var javaScriptCodeToForward = "ext.IDTK_APP.makeCall('hide');";
            return Cocoon.App.forwardAsync(javaScriptCodeToForward);
        }
        else {
            checkEmulatedWebViewReady();
            Cocoon.App.EmulatedWebView.style.display = "none";
        }
    };

    /**
    * Sets a callback function that will be called whenever the system tries to finish the app.
    * The developer can specify how the system will react to the finish of the app by returning a
    * boolean value in the callback function: true means, close the app, false means that the developer
    * will handle the app close.
    * A common example of this is the back button in Android devices. When the back button is pressed, this
    * callback will be called and the system will react depending on the developers choice finishing, or not,
    * the application.
    * @function exitCallback
    * @memberOf Cocoon.App
    * @param {function} callback A function object that will be called when the system
    * determines that the app should be finished. This function must return a true or a false value
    * depending on what the developer wants: true === finish the app, false === do not close the app.
    * @example
    * Cocoon.App.exitCallback(function(){
    *   if(true){
    *       return true; // Finish the app
    *   }else{
    *       return false; // Do not close the app
    *   }  
    * });
    */
    extension.exitCallback = function(appShouldFinishCallback)
    {
        if (navigator.isCocoonJS && Cocoon.App.nativeAvailable)
        {
            window.onidtkappfinish = appShouldFinishCallback;
        }
    }

    /**
    * @private
    * @function forwardedEventFromTheWebView
    * @memberOf Cocoon.App
    */
    extension.forwardedEventFromTheWebView = function(eventName, eventDataString) {
        var eventData = JSON.parse(eventDataString);
        eventData.target = window;
        var event = new Event(eventName);
        for (var att in eventData) {
            event[att] = eventData[att];
        }
        event.target = window;
        window.dispatchEvent(event);
        var canvases = document.getElementsByTagName("canvas");
        for (var i = 0; i < canvases.length; i++) {
            event.target = canvases[i];
            canvases[i].dispatchEvent(event);
        }
    }

    extension.onLoadInTheWebViewSucceed = new Cocoon.EventHandler("IDTK_APP", "App", "forwardpageload");

    extension.onLoadInTheWebViewFailed = new Cocoon.EventHandler("IDTK_APP", "App", "forwardpagefail");

    var signal = new Cocoon.Signal.createSignal();

    signal.register("load", {
        success : extension.onLoadInTheWebViewSucceed,
        error : extension.onLoadInTheWebViewFailed
    });
    
    extension.WebView = Cocoon.WebView || {};
    extension.WebView.on = signal.expose();

    return extension;
});;/**
 * This namespace holds different utilities.
 * @namespace Cocoon.Utils
 */
Cocoon.define("Cocoon.Utils" , function(extension){
    "use strict";

    /**
    * Prints in the console the memory usage of the currently alive textures.
    * @function logMemoryInfo
    * @memberOf Cocoon.Utils
    * @example
    * Cocoon.Utils.logMemoryInfo();
    */
    extension.logMemoryInfo = function()
    {
        if (Cocoon.nativeAvailable && navigator.isCocoonJS)
        {
            return extension.callNative("IDTK_APP", "logMemoryInfo", arguments);
        }
    };

    /**
    * Sets the texture reduction options. The texture reduction is a process that allows big images to be reduced/scaled down when they are loaded.
    * Although the quality of the images may decrease, it can be very useful in low end devices or those with limited amount of memory.
    * The function sets the threshold on image size (width or height) that will be used in order to know if an image should be reduced or not.
    * It also allows to specify a list of strings to identify in which images file paths should be applied (when they meet the size threshold requirement) 
    * The developer will still think that the image is of the original size. CocoonJS handles all of the internals to be able to show the image correctly.
    * IMPORTANT NOTE: This function should be called when the application is initialized before any image is set to be loaded for obvious reasons ;).
    * and in which sould be forbid (even if they meet the threshold requirement).
    * @function setTextureReduction
    * @memberOf Cocoon.Utils
    * @param {number} sizeThreshold This parameter specifies the minimun size (either width or height) that an image should have in order to be reduced.
    * @param {string|array} applyTo This parameter can either be a string or an array of strings. It's purpose is to specify one (the string) or more (the array) substring(s) 
    * that will be compared against the file path of an image to be loaded in order to know if the reduction should be applied or not. If the image meets the
    * threshold size requirement and it's file path contains this string (or strings), it will be reduced. This parameter can also be null.
    * @param {string|array} forbidFor This parameter can either be a string or an array of strings. It's purpose is to specify one (the string) or more (the array) substring(s) 
    * that will be compared against the file path of an image to be loaded in order to know if the reduction should be applied or not. If the image meets the
    * threshold size requirement and it's file path contains this string (or strings), it won't be reduced. This parameter should be used in order to mantain the 
    * quality of some images even they meet the size threshold requirement.
    * @example
    * Cocoon.Utils.textureReduction(64);
    */
    extension.textureReduction = function(sizeThreshold, applyTo, forbidFor)
    {
        if (Cocoon.nativeAvailable && navigator.isCocoonJS)
        {
            extension.callNative("IDTK_APP", "setDefaultTextureReducerThreshold", arguments);
        }
    };

    /**
     * Captures a image of the screen synchronously and saves it to a file. Sync mode allows to capture the screen in the middle of a frame rendering.
     * @function captureScreen
     * @memberof Cocoon.Utils
     * @param {string} fileName Desired file name and format (png or jpg). If no value is passed, "capture.png" value is used by default
     * @param {Cocoon.App.StorageType} storageType The developer can specify the storage where it is stored. If no value is passed, the {@link Cocoon.Utils.StorageType.TMP_STORAGE} value is used by default.
     * @param {Cocoon.App.StorageType} captureType Optional value to choose capture type. See {@link Cocoon.Utils.CaptureType}.
     * - 0: Captures everything.
     * - 1: Only captures cocoonjs surface.
     * - 2: Only captures system views.
     * @throws exception if the image fails to be stored or there is another error.
     * @return The URL of the saved file.
     * @example
     * Cocoon.Utils.captureScreen("myScreenshot.png");
     */
    extension.captureScreen = function (fileName, storageType, captureType) {
        if (Cocoon.nativeAvailable) {
            return window.ext.IDTK_APP.makeCall("captureScreen", fileName, storageType, captureType);
        }
    };

     /**
     * Captures a image of the screen asynchronously and saves it to a file.
     * Async mode captures a final frame as soon as possible.
     * @function captureScreenAsync
     * @memberof Cocoon.Utils
     * @param {string} fileName Desired file name and format (png or jpg). If no value is passed, "capture.png" value is used by default
     * @param {Cocoon.App.StorageType} storageType The developer can specify the storage where it is stored. If no value is passed, the {@see Cocoon.Utils.StorageType.TMP_STORAGE} value is used by default.
     * @param {Cocoon.App.StorageType} captureType Optional value to choose capture type. [0: captures everything, 1: only captures cocoonjs surface, 2: only captures system views]. @see Cocoon.Utils.CaptureType
     * @param {function} callback Response callback, check the error property to monitor errors. Check the 'url' property to get the URL of the saved Image
     * @example
     * Cocoon.Utils.captureScreenAsync("myScreenshot.png", Cocoon.Utils.StorageType.TMP_STORAGE, Cocoon.Utils.CaptureType.EVERYTHING, function(){
     * ...
     * });
     */
    extension.captureScreenAsync = function (fileName, storageType, captureType, callback) {
        if (Cocoon.nativeAvailable) {
            window.ext.IDTK_APP.makeCallAsync("captureScreen", fileName, storageType, captureType, callback);
        }
    };

    /**
    * Activates or deactivates the antialas functionality from the Cocoon rendering.
    * @function setAntialias
    * @memberOf Cocoon.Utils
    * @example
    * Cocoon.Utils.setAntialias(true);
    */
    extension.setAntialias = function(enable)
    {
        if (Cocoon.nativeAvailable && navigator.isCocoonJS)
        {
           return extension.callNative("IDTK_APP", "setDefaultAntialias", arguments);
        }
    };

    /**
     * Enables NPOT (not power of two) textures in Canvas+. 
     * Canvas+ uses POT (power of two) textures by default. Enabling NPOT improves memory usage but may affect performance on old GPUs.
     * @function setNPOTEnabled
     * @memberof Cocoon.Utils
     * @param {boolean} enabled true to enable NPOT Textures
     * @example
     * Cocoon.Utils.setNPOTEnabled(true);
     */
    extension.setNPOTEnabled = function (enabled) {
        if (Cocoon.nativeAvailable && navigator.isCocoonJS) {
            return window.ext.IDTK_APP.makeCall("setNPOTEnabled", enabled);
        }
    };

    /**
     * Sets a max memory threshold in Canvas+ for canvas2D contexts.
     * If the maxMemory is enabled, CocoonJS checks the total amount of texture sizes (images and canvases). 
     * When the memory size reaches the max memory threshold CocoonJS disposes least recently used textures until the memory fits the threshold. 
     * It disposes textures used for JS Image objects (which can be reloaded later if needed).
     * It doesn't dispose canvas objects because they cannot be reconstructed if they are used again in a render operation.
     * @function setMaxMemory
     * @memberof Cocoon.Utils
     * @param {number} memoryInMBs max memory in megabytes
     * @example
     * Cocoon.Utils.setMaxMemory(75);
     */
    extension.setMaxMemory = function (memoryInMBs) {
        if (Cocoon.nativeAvailable && navigator.isCocoonJS) {
            return window.ext.IDTK_APP.makeCall("setMaxMemory", memoryInMBs);
        }
    };

    /**
    * 
    * @memberof Cocoon.Utils
    * @name Cocoon.Utils.CaptureType
    * @property {string} Cocoon.Utils.CaptureType - The base object
    * @property {string} Cocoon.Utils.CaptureType.EVERYTHING - Captures everything, both the CocoonJS GL hardware accelerated surface and the system views (like the WebView).
    * @property {string} Cocoon.Utils.CaptureType.COCOONJS_GL_SURFACE - Captures just the CocoonJS GL hardware accelerated surface.
    * @property {string} Cocoon.Utils.CaptureType.JUST_SYSTEM_VIEWS - Captures just the sustem views (like the webview)
    */
    extension.CaptureType = {
        EVERYTHING:0,
        COCOONJS_GL_SURFACE:1,
        JUST_SYSTEM_VIEWS:2
    };

    /**
    * Queries if a file exists in the specified path and storage type. If none or unknown storage type is specified, the TEMPORARY_STORAGE is used as default.
    * @function existsPath
    * @memberof Cocoon.Utils
    * @param {string} path The relative path to look for inside the storage of the underlying system.
    * @param {Cocoon.App.StorageType} storageType The storage type where to look for the specified path inside the system.
    * @example
    * console.log(Cocoon.Utils.existsPath("file.txt"));
    */
    extension.existsPath = function(path, storageType) {
        if (Cocoon.nativeAvailable){
            return window.ext.IDTK_APP.makeCall("existsPath", path, storageType);
        }
        return false;
    }

    /**
    * Setups the internal text texture cache size.
    * In order to improve the performance of fill and stroke operations, a text texture cache is used internally. Once a text is drawn
    * a texture is stored that matches that text and that text configuration. If the same text is called to 
    * be drawn, this cached texture would be used. 
    * This function allows to set the size of the cache. A value of 0 would mean that no cache
    * will be used. 
    * @function setTextCacheSize
    * @memberof Cocoon.Utils
    * @param size {number} The size of the text cache.
    * @example
    * Cocoon.Utils.setTextCacheSize(32);
    */
    extension.setTextCacheSize = function (size) {
        if (Cocoon.nativeAvailable && navigator.isCocoonJS) {
            return Cocoon.callNative("IDTK_APP", "setTextCacheSize", arguments);
        }
    }

    return extension;

});;/**
* Dialog functions (prompt / confirm).
*
*<div class="alert alert-success">
* <p>Here you will find demos about this namespace: </p> 
* <ul> <li> <a href="https://github.com/ludei/cocoonjs-demos/tree/master/Keyboard">Keyboard demo</a>.</li>
* <li> <a href="https://github.com/ludei/cocoonjs-demos/tree/Vibration">Vibration demo</a>.</li> </ul>
*</div>
* @namespace Cocoon.Dialog
*/
Cocoon.define("Cocoon.Dialog" , function(extension){
    "use strict";

   	/**
     * @property {object} Cocoon.Dialog.keyboardType Types of input keyboard.
     * @property {string} Cocoon.Dialog.keyboardType.TEXT Represents a generic text input keyboard.
     * @property {string} Cocoon.Dialog.keyboardType.NUMBER Represents a number like input keyboard.
     * @property {string} Cocoon.Dialog.keyboardType.PHONE Represents a phone like input keyboard.
     * @property {string} Cocoon.Dialog.keyboardType.EMAIL Represents an email like input keyboard.
     * @property {string} Cocoon.Dialog.keyboardType.URL Represents an URL like input keyboard.
     * @memberOf Cocoon.Dialog
     * @name Cocoon.Dialog.keyboardType
     */
    extension.keyboardType = {

        TEXT:"text",

        NUMBER:"num",

        PHONE:"phone",

        EMAIL:"email",

        URL:"url"
    };

     /**
      * Pops up a text dialog so the user can introduce some text and the application can get it back. It is the first approach CocoonJS has taken to be able to introduce
      * text input in a easy way. The dialog execution events are passed to the application through the {@link Cocoon.Dialog.onTextDialogFinished} and the {@link Cocoon.Dialog.onTextDialogCancelled} event objects.
      * @param {object} param Object information.
      * @param [param.title] {string} The title to be displayed in the dialog.
      * @param [param.message] {string} The message to be displayed in the dialog, next to the text input field.
      * @param [param.text] {string} The initial text to be introduced in the text input field.
      * @param [param.type] {Cocoon.Dialog.keyboardType} Default value is Cocoon.Dialog.keyboardType.TEXT. The keyboard type to be used when the text has to be introduced.
      * @param [param.cancelText] {string} Default value is "Cancel". The text to be displayed in the cancel button of the dialog.
      * @param [param.confirmText] {string} Default value is "Ok". The text to be displayed in the ok button of the dialog.
      * @param {callback} callbacks - <i>success</i> and <i>cancel</i> callbacks called when the user confirms or cancel the dialog.
      * @memberOf Cocoon.Dialog
      * @function prompt
      * @example 
      * Cocoon.Dialog.prompt({ 
      *     title : "title",
      *     message : "message"
      * },{
      *     success : function(text){ ... },
      *     cancel : function(){ ... }
      * });
      */

    extension.prompt = function (params, callbacks) {
        
        if(!callbacks)  throw("Callback missing for Cocoon.Dialog.prompt();");
        var defaultKeyboard = Cocoon.Dialog.keyboardType.TEXT;
        
        switch (params.type){
            case Cocoon.Dialog.keyboardType.TEXT:
                defaultKeyboard = Cocoon.Dialog.keyboardType.TEXT;
            break;
            case Cocoon.Dialog.keyboardType.NUMBER:
                defaultKeyboard = Cocoon.Dialog.keyboardType.NUMBER;
            break;
            case Cocoon.Dialog.keyboardType.PHONE:
                defaultKeyboard = Cocoon.Dialog.keyboardType.PHONE;
            break;
            case Cocoon.Dialog.keyboardType.EMAIL:
                defaultKeyboard = Cocoon.Dialog.keyboardType.EMAIL;
            break;
            case Cocoon.Dialog.keyboardType.URL:
                defaultKeyboard = Cocoon.Dialog.keyboardType.URL;
            break;
        }

        var properties = {
            title : "",
            message : "",
            text : "",
            type : defaultKeyboard,
            cancelText : "Cancel",
            confirmText : "Ok"
        };

        var args = Cocoon.clone(properties,params);

        var succedListener = function(){
            Cocoon.Dialog.onTextDialogCancelled.removeEventListener(errorListener);
            Cocoon.Dialog.onTextDialogFinished.removeEventListener(succedListener);
            callbacks.success.apply(window , Array.prototype.slice.call(arguments));
        };
  
        var errorListener = function(){
            Cocoon.Dialog.onTextDialogCancelled.removeEventListener(errorListener);
            Cocoon.Dialog.onTextDialogFinished.removeEventListener(succedListener);
            callbacks.cancel.apply(window , Array.prototype.slice.call(arguments));
        };

        Cocoon.Dialog.onTextDialogCancelled.addEventListener(errorListener);
        Cocoon.Dialog.onTextDialogFinished.addEventListener(succedListener);

        if (Cocoon.App.nativeAvailable) {
            return Cocoon.callNative("IDTK_APP", "showTextDialog", args, true);
        }else{
            setTimeout(function() {
                var result = prompt(properties.message, properties.text);
                var eventObject = result ? Cocoon.Dialog.onTextDialogFinished : Cocoon.Dialog.onTextDialogCancelled;
                eventObject.notifyEventListeners(result);
            }, 0);
        }
    };

    /**
     * Pops up a message dialog so the user can decide between a yes or no like confirmation.
     * @function
     * @param {object} params
     * @param params.title Default value is "". The title to be displayed in the dialog.
     * @param params.message Default value is "". The message to be displayed in the dialog, next to the text input field.
     * @param params.confirmText Default value is "Ok". The text to be displayed for the confirm button.
     * @param params.cancelText  Default value is "Cancel". The text to be displayed for the deny button.
     * @param {function} callback - Called when the user accepts or cancel the dialog, it receives an argument true/false.
     * @memberOf Cocoon.Dialog
     * @function confirm
     * @example
     * Cocoon.Dialog.confirm({
     *  title : "This is the title",
     *  message : "Awesome message"
     * }, function(accepted){
     *  if(accepted){
     *      alert("The user has accepted the dialog");
     *  }else{
     *      alert("The user has denied the dialog");
     *  }
     * });
     */
    extension.confirm = function (params, callback) {

        if(!callback) throw("Callback missing for Cocoon.Dialog.confirm();");

        var properties = {
            title : "", 
            message : "", 
            cancelText : "Cancel",
            confirmText : "Ok"
        };

        var args = Cocoon.clone(properties,params);

        var succedListener = function(){
            Cocoon.Dialog.onMessageBoxDenied.removeEventListenerOnce(errorListener);
            callback(true);
        };
        
        var errorListener = function(){
            Cocoon.Dialog.onMessageBoxConfirmed.removeEventListenerOnce(succedListener);
            callback(false);
        };

        Cocoon.Dialog.onMessageBoxDenied.addEventListenerOnce(errorListener);
        Cocoon.Dialog.onMessageBoxConfirmed.addEventListenerOnce(succedListener);

        if (Cocoon.nativeAvailable) {
            return Cocoon.callNative("IDTK_APP", "showMessageBox", args, true);
        }else{
            setTimeout(function() {
                var result = confirm(properties.message);
                var eventObject = result ? Cocoon.Dialog.onMessageBoxConfirmed : Cocoon.Dialog.onMessageBoxDenied;
                eventObject.notifyEventListeners();
            }, 0);
        }
    };

    /**
      * Shows a keyboard to receive user input. The developer has to process input events and render the resulting text.
      * @param {object} param Object information.
      * @param [param.type] {Cocoon.Dialog.keyboardType} Default value is Cocoon.Dialog.keyboardType.TEXT. The keyboard type to be used when the text has to be introduced.
      * @param {callback} callbacks - <i>insertText</i>, <i>deleteBackward</i>, <i>done</i>, <i>cancel</i> callbacks called when the user clicks a key, confirms or cancels the keyboard session.
      * @memberOf Cocoon.Dialog
      * @function showKeyboard
      * @example 
      * var text = "";
      * Cocoon.Dialog.showKeyboard({
      *     type: Cocoon.Dialog.keyboardType.TEXT,
      * }, {
      *     insertText: function(inserted) {
      *         text += inserted;
      *         console.log(text);
      *     },
      *     deleteBackward: function() {
      *         text = text.slice(0, text.length - 1);
      *         console.log(text);
      *     },
      *     done: function() {
      *         console.log("user clicked done key");
      *     },
      *     cancel: function() {
      *         console.log("user dismissed keyboard");
      *     }
      * });
      */
    extension.showKeyboard = function(params, callbacks) {
        params = params || {};
        params.type = params.type || Cocoon.Dialog.keyboardType.TEXT;
        var insertCallback = callbacks && callbacks.insertText;
        var deleteCallback = callbacks && callbacks.deleteBackward;
        var doneCallback = callbacks && callbacks.done;
        var cancelCallback =  callbacks && callbacks.cancel;

        if (Cocoon.nativeAvailable) {
            Cocoon.callNative("IDTK_APP", "showKeyboard", 
                [params, insertCallback, deleteCallback, doneCallback, cancelCallback], true);
        }
    };

    /**
      * Dismisses a keyboard which was previusly shown by {@link Cocoon.Dialog.showKeyboard}
      *
      * @memberOf Cocoon.Dialog
      * @function dismissKeyboard
      * @example 
      * var text = "";
      * Cocoon.Dialog.showKeyboard({
      *     type: Cocoon.Dialog.keyboardType.TEXT,
      * }, {
      *     insertText: function(inserted) {
      *         if (inserted === "A") { //Custom keyboard hide
      *             Cocoon.Dialog.dismissKeyboard();
      *         }
      *         text += inserted;
      *         console.log(text);
      *     },
      *     deleteBackward: function() {
      *         text = text.slice(0, text.length - 1);
      *         console.log(text);
      *     },
      *     done: function() {
      *         console.log("user clicked done key");
      *     },
      *     cancel: function() {
      *         console.log("user dismissed keyboard");
      *     }
      * });
      */
    extension.dismissKeyboard = function() {
        if (Cocoon.nativeAvailable) {
            Cocoon.callNative("IDTK_APP", "dismissKeyboard", [], true);
        }
    }

    /**
     * Allows listening to events called when the text dialog is finished by accepting it's content.
     * The callback function's documentation is represented by {@link Cocoon.Dialog.OnTextDialogFinishedListener}
     * @event
     * @static
     * @private
     * @memberOf Cocoon.Dialog
     */
    extension.onTextDialogFinished = new Cocoon.EventHandler("IDTK_APP", "App", "ontextdialogfinish");

    /**
     * Allows listening to events called when the text dialog is finished by dismissing it's content.
     * The callback function does not receive any parameter.
     * @event
     * @static
     * @private
     * @memberOf Cocoon.Dialog
     */
    extension.onTextDialogCancelled = new Cocoon.EventHandler("IDTK_APP", "App", "ontextdialogcancel");

    /**
     * Allows listening to events called when the text dialog is finished by accepting it's content.
     * The callback function does not receive any parameter.
     * @event
     * @static
     * @private
     * @memberOf Cocoon.Dialog
     */
    extension.onMessageBoxConfirmed = new Cocoon.EventHandler("IDTK_APP", "App", "onmessageboxconfirmed");

    /**
     * Allows listening to events called when the text dialog is finished by dismissing it's content.
     * The callback function does not receive any parameter.
     * @event
     * @static
     * @private
     * @memberOf Cocoon.Dialog
     */
    extension.onMessageBoxDenied = new Cocoon.EventHandler("IDTK_APP", "App", "onmessageboxdenied");

    return extension;

});
;/**
* This namespace represents all functionalities available in the WebView environment.
*
* <div class="alert alert-success">
*   Here you will find a demo about this namespace: <a href="https://github.com/ludei/cocoonjs-demos/tree/Webview">Webview demo</a>.
*</div>
*
* @namespace Cocoon.WebView
* @example
* Cocoon.WebView.on("load",{
*   success : function(){
*       Cocoon.App.showTheWebView();
*   },
*   error : function(){
*        console.log("Cannot show the Webview for some reason :/");
*   }
* });
* Cocoon.App.loadInTheWebView("WV.html");
*/

Cocoon.define("Cocoon.WebView" , function(extension){

    if (typeof Cocoon === 'undefined' || Cocoon === null) return extension;
    if (typeof Cocoon.App === 'undefined' || Cocoon.App  === null) return extension;
    if (navigator.isCocoonJS) return extension;

    /**
    * Shows a transparent WebView on top of the Cocoon hardware accelerated environment rendering context.
    * @function show
    * @memberof Cocoon.WebView
    * @param {number} [x] The horizontal position where to show the WebView.
    * @param {number} [y] The vertical position where to show the WebView.
    * @param {number} [width] The horitonzal size of the WebView.
    * @param {number} [height] the vertical size of the WebView.
    */
    extension.show = function(x, y, width, height)
    {
        if (Cocoon.App.nativeAvailable)
        {
           return Cocoon.callNative("IDTK_APP", "show", arguments);
        }
        else
        {
            var div = window.parent.document.getElementById('CocoonJS_App_ForCocoonJS_WebViewDiv');
            div.style.left = (x ? x : div.style.left)+'px';
            div.style.top = (y ? y : div.style.top)+'px';
            div.style.width = (width ? width/window.devicePixelRatio : window.parent.innerWidth)+'px';
            div.style.height = (height ? height/window.devicePixelRatio : window.parent.innerHeight)+'px';
            div.style.display = "block";
            var iframe = window.parent.document.getElementById('CocoonJS_App_ForCocoonJS_WebViewIFrame');
            iframe.style.width = (width ? width/window.devicePixelRatio : window.parent.innerWidth)+'px';
            iframe.style.height = (height ? height/window.devicePixelRatio : window.parent.innerHeight)+'px';
        }
    };

    /**
    * Hides the transparent WebView on top of the Cocoon hardware acceleration environment rendering contect.
    * @function hide
    * @memberof Cocoon.WebView
    */
    extension.hide = function()
    {
        if (Cocoon.App.nativeAvailable)
        {
           return Cocoon.callNative("IDTK_APP", "hide", arguments);
        }
        else
        {
            window.parent.document.getElementById('CocoonJS_App_ForCocoonJS_WebViewDiv').style.display = "none";
        }
    };

    /**
    * Loads a resource in the Cocoon environment from the WebView environment. 
    * @function loadInCocoon
    * @memberof Cocoon.WebView
    * @param {string} path The path to the resource. It can be a remote URL or a path to a local file.
    * @param {callbacks} cb - An object containing two callbacks, { success : callback, error: callback }.
    * @param {Cocoon.App.StorageType} [storageType] An optional parameter to specify at which storage in the device the file path is stored. By default, APP_STORAGE is used.
    * <br/> success: This callback function allows listening to events called when the Cocoon load has completed successfully.
    * <br/> error: This callback function allows listening to events called when the Cocoon load fails.
    * @example
    * Cocoon.WebView.loadInCocoon("index.html", {
    *   success : function(){ ... },
    *   error : function(){ ... }
    * });
    */
    extension.loadInCocoon = function(path, callbacks, storageType)
    {
        if (Cocoon.App.nativeAvailable)
        {
            var javaScriptCodeToForward = "ext.IDTK_APP.makeCall('loadPath'";
            if (typeof path !== 'undefined')
            {
                javaScriptCodeToForward += ", '" + path + "'";
                if (typeof storageType !== 'undefined')
                {
                    javaScriptCodeToForward += ", '" + storageType + "'";
                }
            }
            javaScriptCodeToForward += ");";

            return Cocoon.App.forwardAsync(javaScriptCodeToForward);
        }
        else
        {
            Cocoon.App.forwardAsync("Cocoon.App.load('" + path + "');");
        }
    };

    extension.reloadCocoonJS = function()
    {
        if (Cocoon.App.nativeAvailable)
        {
            return Cocoon.App.forwardAsync("ext.IDTK_APP.makeCall('reload');");
        }
        else if (!navigator.isCocoonJS)
        {
            window.parent.location.reload();
        }
    };


    window.addEventListener("load", function()
    {
        

        // Only if we are completely outside CocoonJS (or CocoonJS' webview),
        // setup event forwarding from the webview (iframe) to Cocoon.
        if (!Cocoon.App.nativeAvailable && window.name == 'CocoonJS_App_ForCocoonJS_WebViewIFrame') {
            Cocoon.App.forwardEventsToCocoonJSEnabled = false;
            var EVENT_ATTRIBUTES = [ 'timeStamp', 'button', 'type', 'x', 'y', 'pageX', 'pageY', 'clientX', 'clientY', 'offsetX', 'offsetY'];
            var EVENTS = [ "dblclick", "touchmove", "mousemove", "touchend", "touchcancel", "mouseup", "touchstart", "mousedown", "release", "dragleft", "dragright", "swipeleft", "swiperight" ];
            function forwardEventToCocoonJS(eventName, event) {
                var eventData = {};
                var att, i;
                for (var att in event) {
                    i = EVENT_ATTRIBUTES.indexOf(att);
                    if (i >= 0) {
                        eventData[att] = event[att];
                    }
                }
                var jsCode = "Cocoon && Cocoon.App && Cocoon.App.forwardedEventFromTheWebView && Cocoon.App.forwardedEventFromTheWebView(" + JSON.stringify(eventName) + ", '" + JSON.stringify(eventData) + "');";
                Cocoon.App.forward(jsCode);
            }
            for (i = 0; i < EVENTS.length; i++) {
                window.addEventListener(EVENTS[i], (function(eventName) {
                    return function(event) {
                        if (Cocoon.App.forwardEventsToCocoonJSEnabled) {
                            forwardEventToCocoonJS(eventName, event);
                        }
                    };
                })(EVENTS[i]));
            }
        }

    });

    extension.onLoadInCocoonJSSucceed = new Cocoon.EventHandler("IDTK_APP", "App", "forwardpageload");

    extension.onLoadInCocoonJSFailed = new Cocoon.EventHandler("IDTK_APP", "App", "forwardpagefail");

    return extension;
});;Cocoon.define("Cocoon.Proxify" , function(extension){
    "use strict";
    /**
    * Proxies different functions of the WebView environment, like Audio objects and XHR.
    * @namespace Cocoon.Proxify
    */

    /**
    * @function getKeyForValueInDictionary
    * @memberof Cocoon.WebView
    * @private
    */
    extension.getKeyForValueInDictionary = function(dictionary, value) {
        var finalKey = null;
        for (var key in dictionary) {
            if (dictionary[key] === value){
                finalKey = key;
                break;
            }
        }
        return finalKey;
    }

    /**
    * Setups a origin proxy for a given typeName. What this means is that after calling this function the environment that makes this call will suddenly
    * have a way of creating instances of the given typeName and those instances will act as a transparent proxy to counterpart instances in the destination environment.
    * Manipulating attributes, calling funcitions or handling events will all be performed in the destination environment but the developer will think they will be
    * happening in the origin environment.
    * IMPORTANT NOTE: These proxies only work with types that use attributes and function parameters and return types that are primitive like numbers, strings or arrays.
    * @function setupOriginProxyType
    * @memberof Cocoon.Proxify
    * @private
    * @param {string} typeName The name of the type to be proxified.
    * @param {array} [attributeNames] A list of the names of the attributes to be proxified.
    * @param {array} [functionNames] A list of the names of the functions to be proxified.
    * @param {array} [eventHandlerNames] A list of the names of the event handlers to be proxified (onXXXX like attributes that represent callbacks).
    * A valid typeName and at least one valid array for attribute, function or event handler names is mandatory.
    */
    extension.setupOriginProxyType = function (typeName, attributeNames, functionNames, eventHandlerNames) {
        if (Cocoon.nativeAvailable){
            // Control the parameters.
            if (!typeName) throw "The given typeName must be valid.";
            if (!attributeNames && !functionNames && !eventHandlerNames) throw "There is no point on setting up a proxy for no attributes, functions nor eventHandlers.";
            attributeNames = attributeNames ? attributeNames : [];
            functionNames = functionNames ? functionNames : [];
            eventHandlerNames = eventHandlerNames ? eventHandlerNames : [];

            // The parent object will be the window. It could be another object but careful, the destination side should know about this.
            // TODO: Specify the parentObject as a parameter, obtain it's path from the window object and pass it to the destination environment so it knows about it.
            var parentObject = window;

            // Setup the destination side too.
            var jsCode = "Cocoon.Proxify.setupDestinationProxyType(" + JSON.stringify(typeName) + ", " + JSON.stringify(eventHandlerNames) + ");";
            Cocoon.App.forward(jsCode);

            var originalType = parentObject[typeName];

            // Constructor. This will be the new proxified type in the origin environment. Instances of this type will be created by the developer without knowing that they are
            // internally calling to their counterparts in the destination environment.
            parentObject[typeName] = function () {
                var _this = this;

                // Each proxy object will have a origin object inside with all the necessary information to be a proxy to the destination.
                this._cocoonjs_proxy_object_data = {};
                // The id is obtained calling to the destination side to create an instance of the type.
                var jsCode = "Cocoon.Proxify.newDestinationProxyObject(" + JSON.stringify(typeName) + ");";
                this._cocoonjs_proxy_object_data.id = Cocoon.App.forward(jsCode);
                // The eventHandlers dictionary contains objects of the type { eventHandlerName : string, eventHandler : function } to be able to make the callbacks when the 
                // webview makes the corresponding calls.
                this._cocoonjs_proxy_object_data.eventHandlers = {};
                // Also store the typename inside each instance.
                this._cocoonjs_proxy_object_data.typeName = typeName;
                // A dictionary to store the event handlers
                this._cocoonjs_proxy_object_data.eventListeners = {};

                // TODO: eventHandlers and eventListeners should be in the same list ;)

                // Store all the proxy instances in a list that belongs to the type itself.
                parentObject[typeName]._cocoonjs_proxy_type_data.proxyObjects[this._cocoonjs_proxy_object_data.id] = this;

                // Create a setter and a getter for all the attribute names that have been specified. When the attributes are accessed (set or get) a call to the destination counterpart will be performed.
                for (var i = 0; i < attributeNames.length; i++) {
                    (function (attributeName) {
                        _this.__defineSetter__(attributeName, function (value) {
                            var jsCode = "Cocoon.Proxify.setDestinationProxyObjectAttribute(" + JSON.stringify(typeName) + ", " + _this._cocoonjs_proxy_object_data.id + ", " + JSON.stringify(attributeName) + ", " + JSON.stringify(value) + ");";
                            return Cocoon.App.forward(jsCode);
                        });
                        _this.__defineGetter__(attributeName, function () {
                            var jsCode = "Cocoon.Proxify.getDestinationProxyObjectAttribute(" + JSON.stringify(typeName) + ", " + _this._cocoonjs_proxy_object_data.id + ", " + JSON.stringify(attributeName) + ");";
                            return Cocoon.App.forward(jsCode);
                        });
                    })(attributeNames[i]);
                }

                // Create a function that performs a call to the destination environment counterpart for all the function names that have been specified.
                for (var i = 0; i < functionNames.length; i++) {
                    (function (functionName) {
                        _this[functionName] = function () {
                            // Get the arguments as an array and add the typeName, the proxy id and the functionName before all the other arguments before making the call to the destination counterpart.
                            var argumentsArray = Array.prototype.slice.call(arguments);
                            argumentsArray.unshift(functionName);
                            argumentsArray.unshift(this._cocoonjs_proxy_object_data.id);
                            argumentsArray.unshift(typeName);
                            // Use the array to create the correct function call.
                            var jsCode = "Cocoon.Proxify.callDestinationProxyObjectFunction(";
                            for (var i = 0; i < argumentsArray.length; i++) {
                                // The second argument (the id) should not be stringified
                                jsCode += (i !== 1 ? JSON.stringify(argumentsArray[i]) : argumentsArray[i]) + (i < argumentsArray.length - 1 ? ", " : "");
                            }
                            jsCode += ");";
                            // TODO: This next call should be synchronous but it seems that some customers are experiencing some crash issues. Making it async solves these crashes.
                            // Another possible solution could be to be able to specify which calls could be async and which sync in the proxification array.
                            var ret = Cocoon.App.forwardAsync(jsCode);
                            return ret;
                        };
                    })(functionNames[i]);
                }

                // Create a setter and getter for all the event handler names that have been specified. When the event handlers are accessed, store them inside the corresponding position on the eventHandlers
                // array so they can be called when the destination environment makes the corresponding callback call.
                for (var i = 0; i < eventHandlerNames.length; i++) {
                    (function (eventHandlerName) {
                        _this.__defineSetter__(eventHandlerName, function (value) {
                            _this._cocoonjs_proxy_object_data.eventHandlers[eventHandlerName] = value;
                        });
                        _this.__defineGetter__(eventHandlerName, function () {
                            return _this._cocoonjs_proxy_object_data.eventHandlers[eventHandlerName];
                        });
                    })(eventHandlerNames[i]);
                }

                // Setup the add and remove event listeners in the proxy object
                _this.addEventListener = function (eventTypeName, eventCallback) {
                    var addEventCallback = true;
                    // Check for the eventListeners
                    var eventListeners = _this._cocoonjs_proxy_object_data.eventListeners[eventTypeName];
                    if (eventListeners) {
                        // As the eventListeners were already added, check that the same callback has not been added.
                        addEventCallback = eventListeners.indexOf(eventCallback) < 0;
                    }
                    else {
                        // There are no event listeners, so add the one and add the listeners array for the specific event type name
                        eventListeners = [];
                        _this._cocoonjs_proxy_object_data.eventListeners[eventTypeName] = eventListeners;

                        // Forward the call so the other end registers a event listener (only one is needed).
                        var jsCode = "Cocoon.Proxify.addDestinationProxyObjectEventListener(" + JSON.stringify(_this._cocoonjs_proxy_object_data.typeName) + ", " + _this._cocoonjs_proxy_object_data.id + ", " + JSON.stringify(eventTypeName) + ");";
                        Cocoon.App.forwardAsync(jsCode);
                    }
                    // Only if the alforithm above specify so, add the eventcallback and notify the destination environment to do the same
                    if (addEventCallback) {
                        eventListeners.push(eventCallback);
                    }
                };

                _this.removeEventListener = function (eventTypeName, eventCallback) {
                    // Check for the eventListeners
                    var eventListeners = _this._cocoonjs_proxy_object_data.eventListeners[eventTypeName];
                    if (eventListeners) {
                        var eventCallbackIndex = eventListeners.indexOf(eventCallback);
                        if (eventCallbackIndex >= 0) {
                            eventListeners.splice(eventCallbackIndex, 1);
                        }
                    }
                };

                // Return the proxy instance.
                return this;
            };

            // The type will contain a proxy data structure to store all the instances that are created so they are available when the destination environment calls back. 
            parentObject[typeName]._cocoonjs_proxy_type_data =
            {
                originalType:originalType,
                proxyObjects:[]
            };

            /**
             * Deletes a proxy instance from both the CocoonJS environment structures and also deleting it's webview environment counterpart.
             * This function should be manually called whenever a proxy instance won't be accessed anymore.
             * @param {object} object The proxy object to be deleted.
             */
            parentObject[typeName]._cocoonjs_proxy_type_data.deleteProxyObject = function (object) {
                var proxyObjectKey = extension.getKeyForValueInDictionary(this.proxyObjects, object);
                if (proxyObjectKey) {
                    var jsCode = "Cocoon.Proxify.deleteDestinationProxyObject(" + JSON.stringify(typeName) + ", " + object._cocoonjs_proxy_object_data.id + ");";
                    Cocoon.App.forwardAsync(jsCode);
                    object._cocoonjs_proxy_object_data = null;
                    delete this.proxyObjects[proxyObjectKey];
                }
            };

            /**
             * Calls an event handler for the given proxy object id and an eventHandlerName.
             * @param {number} id The id to be used to look for the proxy object for which to make the call to it's event handler.
             * @param {string} eventHandlerName The name of the handler to be called.
             * NOTE: Events are a complex thing in the HTML specification. This function just performs a call but at least provides a
             * structure to the event passing the target (the proxy object).
             * TODO: The destination should serialize the event object as far as it can so many parameters can be passed to the origin
             * side. Using JSON.stringify in the destination side and parse in origin side maybe? Still must add the target to the event structure though.
             */
            parentObject[typeName]._cocoonjs_proxy_type_data.callProxyObjectEventHandler = function (id, eventHandlerName) {
                var object = this.proxyObjects[id];
                var eventHandler = object._cocoonjs_proxy_object_data.eventHandlers[eventHandlerName];
                if (eventHandler) {
                    eventHandler({ target:object });
                }
            };

            parentObject[typeName]._cocoonjs_proxy_type_data.callProxyObjectEventListeners = function (id, eventTypeName) {
                var object = this.proxyObjects[id];
                var eventListeners = object._cocoonjs_proxy_object_data.eventListeners[eventTypeName].slice();
                for (var i = 0; i < eventListeners.length; i++) {
                    eventListeners[i]({ target:object });
                }
            };
        }
    };

    /**
    * Takes down the proxification of a type and restores it to it's original type. Do not worry if you pass a type name that is not proxified yet. The
    * function will handle it correctly for compativility reasons.
    * @function takedownOriginProxyType
    * @memberof Cocoon.Proxify
    * @private
    * @param {string} typeName The name of the type to be deproxified (take down the proxification and restore the type to it's original state)
    */
    extension.takedownOriginProxyType = function (typeName) {
        if (Cocoon.App.nativeAvailable) {
            var parentObject = window;
            if (parentObject[typeName] && parentObject[typeName]._cocoonjs_proxy_type_data) {
                parentObject[typeName] = parentObject[typeName]._cocoonjs_proxy_type_data.originalType;
            }
        }
    };

    /**
    * Deletes everything related to a proxy object in both environments. Do not worry of you do not pass a proxified object to the
    * function. For compatibility reasons, you can still have calls to this function even when no poxification of a type has been done.
    * @function deleteOriginProxyObject
    * @memberof Cocoon.Proxify
    * @private
    * @param {object} object The proxified object to be deleted.
    */
    extension.deleteOriginProxyObject = function (object) {
        if (Cocoon.App.nativeAvailable) {
            var parentObject = window;
            if (object && object._cocoonjs_proxy_object_data) {
                parentObject[object._cocoonjs_proxy_object_data.typeName]._cocoonjs_proxy_type_data.deleteProxyObject(object);
            }
        }
    };

    /**
    * Calls the origin proxy object when an event handler need to be updated/called from the destination environment.
    * @function callOriginProxyObjectEventHandler
    * @memberof Cocoon.Proxify
    * @private
    * @param {string} typeName The type name of the proxified type.
    * @param {number} id The id of the proxy object.
    * @param {string} eventHandlerName The name of the event handler to be called.
    */
    extension.callOriginProxyObjectEventHandler = function (typeName, id, eventHandlerName) {
        if (Cocoon.App.nativeAvailable) {
            var parentObject = window;
            parentObject[typeName]._cocoonjs_proxy_type_data.callProxyObjectEventHandler(id, eventHandlerName);
        }
    };

    /**
    * Calls the origin proxy object when all the event listeners related to a specific event need to be updated/called from the destination environment.
    * @function callOriginProxyObjectEventListeners
    * @memberof Cocoon.Proxify
    * @private
    * @param {string} typeName The type name of the proxified type.
    * @param {number} id The id of the proxy object.
    * @param {string} eventTypeName The name of the event type to call the listeners related to it.
    */
    extension.callOriginProxyObjectEventListeners = function (typeName, id, eventTypeName) {
        if (Cocoon.App.nativeAvailable) {
            var parentObject = window;
            parentObject[typeName]._cocoonjs_proxy_type_data.callProxyObjectEventListeners(id, eventTypeName);
        }
    };

    /**
    * Setups all the structures that are needed to proxify a destination type to an origin type.
    * @function setupDestinationProxyType
    * @memberof Cocoon.Proxify
    * @private
    * @param {string} typeName The name of the type to be proxified.
    * @param {array} eventHandlerNames An array with al the event handlers to be proxified. Needed in order to be able to create callbacks for all the event handlers
    * and call to the CocoonJS counterparts accordingly.
    */
    extension.setupDestinationProxyType = function (typeName, eventHandlerNames) {
        if (Cocoon.App.nativeAvailable) {
            var parentObject = window;

            // Add a cocoonjs structure to the destination proxified type to store some useful information like all the proxy instances that are created, plus the id counter 
            // and the names of all the event handlers and some utility functions.
            parentObject[typeName]._cocoonjs_proxy_type_data =
            {
                nextId:0,
                proxyObjects:{},
                eventHandlerNames:eventHandlerNames
            }
        }
    };

    /**
    * Takes down the proxy type at the destination environment. Just removes the data structure related to proxies that was added to the type when proxification tool place.
    * @function takedownDestinationProxyType
    * @memberof Cocoon.Proxify
    * @private
    * @param {string} typeName The name of the type to take the proxification down.
    */
    extension.takedownDestinationProxyType = function (typeName) {
        if (Cocoon.App.nativeAvailable) {
            var parentObject = window;
            if (parent[typeName] && parentObject[typeName]._cocoonjs_proxy_type_data) {
                delete parentObject[typeName]._cocoonjs_proxy_type_data;
            }
        }
    };

    /**
    * Creates a new destination object instance and generates a id to reference it from the original environment.
    * @function newDestinationProxyObject
    * @memberof Cocoon.Proxify
    * @private
    * @param {string} typeName The name of the type to be proxified and to generate an instance.
    * @return The id to be used from the original environment to identify the corresponding destination object instance.
    */
    extension.newDestinationProxyObject = function (typeName) {
        if (Cocoon.App.nativeAvailable) {
            var parentObject = window;

            var proxyObject = new parentObject[typeName]();
            // Also store some additional information in the proxy object
            proxyObject._cocoonjs_proxy_object_data = {};
            // Like the type name, that could be useful late ;)
            proxyObject._cocoonjs_proxy_object_data.typeName = typeName;
            // Caculate the id for the object. It will be returned to the origin environment so this object can be referenced later
            var proxyObjectId = parentObject[typeName]._cocoonjs_proxy_type_data.nextId;
            // Store the created object in the structure defined in the setup of proxification with an id associated to it
            parentObject[typeName]._cocoonjs_proxy_type_data.proxyObjects[proxyObjectId] = proxyObject;
            // Also store the id inside the proxy object itself
            proxyObject._cocoonjs_proxy_object_data.id = proxyObjectId;
            // Calculate a new id for the next object.
            parentObject[typeName]._cocoonjs_proxy_type_data.nextId++;

            // Setup all the event handlers.
            for (var i = 0; i < parentObject[typeName]._cocoonjs_proxy_type_data.eventHandlerNames.length; i++) {
                (function (eventHandlerName) {
                    proxyObject[eventHandlerName] = function (event) {
                        var proxyObject = this; // event.target;
                        // var eventHandlerName = Cocoon.getKeyForValueInDictionary(proxyObject, this); // Avoid closures ;)
                        var jsCode = "Cocoon.App.callOriginProxyObjectEventHandler(" + JSON.stringify(proxyObject._cocoonjs_proxy_object_data.typeName) + ", " + proxyObject._cocoonjs_proxy_object_data.id + ", " + JSON.stringify(eventHandlerName) + ");";
                        Cocoon.App.forwardAsync(jsCode);
                    };
                })(parentObject[typeName]._cocoonjs_proxy_type_data.eventHandlerNames[i]);
            }

            // Add the dictionary where the event listeners (callbacks) will be added.
            proxyObject._cocoonjs_proxy_object_data.eventListeners = {};

            return proxyObjectId;
        }
    };

    /**
    * Calls a function of a destination object idetified by it's typeName and id.
    * @function callDestinationProxyObjectFunction
    * @memberof Cocoon.Proxify
    * @private
    * @param {string} typeName The name of the type of the proxy.
    * @param {number} id The id of the proxy object.
    * @param {string} functionName The name of the function to be called.
    * @return Whatever the function call returns.
    */
    extension.callDestinationProxyObjectFunction = function (typeName, id, functionName) {
        if (Cocoon.App.nativeAvailable) {
            var parentObject = window;
            var argumentsArray = Array.prototype.slice.call(arguments);
            argumentsArray.splice(0, 3);
            var proxyObject = parentObject[typeName]._cocoonjs_proxy_type_data.proxyObjects[id];
            var result = proxyObject[functionName].apply(proxyObject, argumentsArray);
            return result;
        }
    };

    /**
    * Sets a value to the corresponding attributeName of a proxy object represented by it's typeName and id.
    * @function setDestinationProxyObjectAttribute
    * @memberof Cocoon.Proxify
    * @private
    * @param {string} typeName The name of the type of the proxy.
    * @param {number} id The id of the proxy object.
    * @param {string} attributeName The name of the attribute to be set.
    * @param {unknown} attributeValue The value to be set to the attribute.
    */
    extension.setDestinationProxyObjectAttribute = function (typeName, id, attributeName, attributeValue) {
        if (Cocoon.App.nativeAvailable) {
            var parentObject = window;
            var proxyObject = parentObject[typeName]._cocoonjs_proxy_type_data.proxyObjects[id];
            proxyObject[attributeName] = attributeValue;
        }
    };

    /**
    * Retrieves the value of the corresponding attributeName of a proxy object represented by it's typeName and id.
    * @function getDestinationProxyObjectAttribute
    * @memberof Cocoon.Proxify
    * @private
    * @param {string} typeName The name of the type of the proxy.
    * @param {number} id The id of the proxy object.
    * @param {string} attributeName The name of the attribute to be retrieved.
    */
    extension.getDestinationProxyObjectAttribute = function (typeName, id, attributeName) {
        if (Cocoon.App.nativeAvailable) {
            var parentObject = window;
            var proxyObject = parentObject[typeName]._cocoonjs_proxy_type_data.proxyObjects[id];
            return proxyObject[attributeName];
        }
    };

    /**
    * Deletes a proxy object identifying it using it's typeName and id. Deleting a proxy object mainly means to remove the instance from the global structure
    * that hold all the instances.
    * @function deleteDestinationProxyObject
    * @memberof Cocoon.Proxify
    * @private
    * @param {string} typeName The name of the type of the proxy.
    * @param {number} id The id of the proxy object.
    */
    extension.deleteDestinationProxyObject = function (typeName, id) {
        if (Cocoon.App.nativeAvailable) {
            var parentObject = window;
            delete parentObject[typeName]._cocoonjs_proxy_type_data.proxyObjects[id];
        }
    };

    /**
    * @function addDestinationProxyObjectEventListener
    * @memberof Cocoon.Proxify
    * @private
    */
    extension.addDestinationProxyObjectEventListener = function (typeName, id, eventTypeName) {
        if (Cocoon.App.nativeAvailable) {
            var parentObject = window;
            // Look for the proxy object
            var proxyObject = parentObject[typeName]._cocoonjs_proxy_type_data.proxyObjects[id];

            var callback = function (event) {
                var proxyObject = this; // event.target;
                // var eventTypeName = Cocoon.getKeyForValueInDictionary(proxyObject._cocoonjs_proxy_object_data.eventListeners, this); // Avoid closures ;)
                // TODO: Is there a way to retrieve the callbackId without a closure?
                var jsCode = "Cocoon.Proxify.callOriginProxyObjectEventListeners(" + JSON.stringify(proxyObject._cocoonjs_proxy_object_data.typeName) + ", " + proxyObject._cocoonjs_proxy_object_data.id + ", " + JSON.stringify(eventTypeName) + ");";
                Cocoon.App.forwardAsync(jsCode);
            };

            proxyObject._cocoonjs_proxy_object_data.eventListeners[eventTypeName] = callback;

            // Finally add the event listener callback to the proxy object
            proxyObject.addEventListener(eventTypeName, callback);
        }
    };

    /**
    * Proxifies the XMLHttpRequest type for the environment where this call is made. After calling this function, all the new objects
    * of XMLHttpRequest that are instantiated, will be proxified objects that will make calls to the counterparts in the other environment (CocoonJS <-> WebView viceversa).
    * IMPORTANT NOTE: Remember to take down the proxification once you are done or to delete proxy objects whenever they are not needed anymore or memory leaks may occur.
    * @function xhr
    * @memberof Cocoon.Proxify
    * @example
    * Cocoon.Proxify.xhr();
    */
    extension.xhr = function () {
        var ATTRIBUTE_NAMES =
            [
                "timeout",
                "withCredentials",
                "upload",
                "status",
                "statusText",
                "responseType",
                "response",
                "responseText",
                "responseXML",
                "readyState"
            ];
        var FUNCTION_NAMES =
            [
                "open",
                "setRequestHeader",
                "send",
                "abort",
                "getResponseHeader",
                "getAllResponseHeaders",
                "overrideMimeType"
            ];
        var EVENT_HANDLER_NAMES =
            [
                "onloadstart",
                "onprogress",
                "onabort",
                "onerror",
                "onload",
                "ontimeout",
                "onloadend",
                "onreadystatechange"
            ];
        Cocoon.Proxify.setupOriginProxyType("XMLHttpRequest", ATTRIBUTE_NAMES, FUNCTION_NAMES, EVENT_HANDLER_NAMES);
    };

    /**
    * Proxifies the Audio type for the environment where this call is made. After calling this function, all the new objects
    * of Audio that are instantiated, will be proxified objects that will make calls to the counterparts in the other environment (CocoonJS <-> WebView viceversa).
    * IMPORTANT NOTE: Remember to take down the proxification once you are done or to delete proxy objects whenever they are not needed anymore or memory leaks may occur.
    * @function audio
    * @memberof Cocoon.Proxify
    * @example
    * Cocoon.Proxify.audio();
    */
    extension.audio = function () {
        var ATTRIBUTE_NAMES =
            [
                "src",
                "loop",
                "volume",
                "preload"
            ];
        var FUNCTION_NAMES =
            [
                "play",
                "pause",
                "load",
                "canPlayType"
            ];
        var EVENT_HANDLER_NAMES =
            [
                "onended",
                "oncanplay",
                "oncanplaythrough",
                "onerror"
            ];
        Cocoon.Proxify.setupOriginProxyType("Audio", ATTRIBUTE_NAMES, FUNCTION_NAMES, EVENT_HANDLER_NAMES);
    };


    /**
    * This function allows to forward console messages from the WebView to the CocoonJS
    * debug console. What it does is to change the console object for a new one
    * with all it's methods (log, error, info, debug and warn) forwarding their
    * messages to the CocoonJS environment.
    * The original console object is stored in the Cocoon.originalConsole property.
    * @function console
    * @memberof Cocoon.Proxify
    * @example
    * Cocoon.Proxify.console();
    */
    extension.console = function() 
    {
        if (!Cocoon.nativeAvailable) return;

        if (typeof Cocoon.originalConsole === 'undefined')
        {
            Cocoon.originalConsole = window.console;
        }
        var functions = ["log", "error", "info", "debug", "warn"];

        var newConsole = {};
        for (var i = 0; i < functions.length; i++)
        {
            newConsole[functions[i]] = function(functionName)
            {
                return function(message)
                {
                    try{
                        var jsCode = "Proxified log: " + JSON.stringify(message);
                        Cocoon.originalConsole.log(jsCode);
                        ext.IDTK_APP.makeCallAsync("forward", jsCode);
                    }catch(e){
                        console.log("Proxified log: " + e);
                    }
                };
            }(functions[i]);
        }
        if (!newConsole.assert) {
            newConsole.assert = function assert() {
                if (arguments.length > 0 && !arguments[0]) {
                    var str = 'Assertion failed: ' + (arguments.length > 1 ? arguments[1] : '');
                    newConsole.error(str);
                }
            }
        }        
        window.console = newConsole;
    };

    /**
    * This function restores the original console object and removes the proxified console object.
    * @function deproxifyConsole
    * @memberof Cocoon.Proxify
    * @example
    * Cocoon.Proxify.deproxifyConsole();
    */
    extension.deproxifyConsole = function()
    {
        if (window.navigator.isCocoonJS || !Cocoon.nativeAvailable) return;
        if (typeof Cocoon.originalConsole !== 'undefined')
        {
            window.console = Cocoon.originalConsole;
            Cocoon.originalConsole = undefined;
        }
    };

    return extension;

});;Cocoon.define("Cocoon.Device" , function(extension){
    "use strict";
    /**
    * All functions related to the device.
    * @namespace Cocoon.Device
    */

    /**
     * An object that defines the getDeviceInfo returned information.
     * @memberof Cocoon.Device
     * @name DeviceInfo
     * @property {object} Cocoon.Device.DeviceInfo - The object itself
     * @property {string} Cocoon.Device.DeviceInfo.os The operating system name (ios, android,...).
     * @property {string} Cocoon.Device.DeviceInfo.version The operating system version (4.2.2, 5.0,...).
     * @property {string} Cocoon.Device.DeviceInfo.dpi The operating system screen density in dpi.
     * @property {string} Cocoon.Device.DeviceInfo.brand  The device manufacturer (apple, samsung, lg,...).
     * @property {string} Cocoon.Device.DeviceInfo.model The device model (iPhone 4S, SAMSUNG-SGH-I997, SAMSUNG-SGH-I997R, etc).
     * @property {string} Cocoon.Device.DeviceInfo.imei The phone IMEI.
     * <br/>Android: The phone IMEI is returned or null if the device has not telepohny.
     * <br/>iOS: null is returned as we cannot get the IMEI in iOS, no public API available for that yet.
     * @property {string} Cocoon.Device.DeviceInfo.platformId The platform Id.
     * @property {string} Cocoon.Device.DeviceInfo.odin The Odin generated id: https://code.google.com/p/odinmobile/
     * @property {string} Cocoon.Device.DeviceInfo.openudid The OpenUDID generated Id: https://github.com/ylechelle/OpenUDID
     */
    extension.DeviceInfo = {
        os:         null,
        version:    null,
        dpi:        null,
        brand:      null,
        model:      null,
        imei:       null,
        platformId: null,
        odin:       null,
        openudid:   null
    };

    /**
    * Returns the device UUID.
    * @function getDeviceId
    * @memberof Cocoon.Device
    * @return {string} The device UUID
    * @example
    * console.log(Cocoon.Device.getDeviceId());
    */
    extension.getDeviceId = function() {
        if (Cocoon.nativeAvailable) {
            return window.ext.IDTK_APP.makeCall("getDeviceId");
        }
    };

    /**
     * Returns the device Info.
     * @function getDeviceInfo
     * @memberof Cocoon.Device
     * @return {Cocoon.Device.DeviceInfo} The device Info
     * @example
     * console.log( JSON.stringify(Cocoon.Device.getDeviceInfo()) );
     */
    extension.getDeviceInfo = function() {
        if (Cocoon.nativeAvailable) {
            return window.ext.IDTK_APP.makeCall("getDeviceInfo");
        }
    };

    /**
    * Retrieves the preferred orientation that has been set in the system.
    * @function getOrientation
    * @memberof Cocoon.Device
    * @return {number} The preferred orientation in the system as a combination of the possible {@link Cocoon.Device.Orientations}.
    * @example
    * console.log(Cocoon.Device.getOrientation());
    */
    extension.getOrientation = function() {
        if (Cocoon.nativeAvailable) {
            return window.ext.IDTK_APP.makeCall("getPreferredOrientation");
        }
        else {
            return 0;
        }
    };

    /**
    * Sets the preferred orientation in the system.
    * @function setOrientation
    * @memberof Cocoon.Device
    * @param {number} preferredOrientation The preferred orientation to be set. A combination of the possible {@link Cocoon.Device.Orientations}.
    * @example
    * Cocoon.Device.setOrientation(Cocoon.Device.Orientations.PORTRAIT);
    */
    extension.setOrientation = function(preferredOrientation) {
        if (Cocoon.nativeAvailable) {
            window.ext.IDTK_APP.makeCall("setPreferredOrientation", preferredOrientation);
        }
    }

    /**
     * The predefined possible orientations. There can be a bit level combination of them using the OR operator.
     * @memberof Cocoon.Device
     * @name Cocoon.Device.Orientations
     * @property {string} Cocoon.Device.Orientations - The base object
     * @property {string} Cocoon.Device.Orientations.PORTRAIT - Portrait
     * @property {string} Cocoon.Device.Orientations.PORTRAIT_UPSIDE_DOWN - Portrait upside-down
     * @property {string} Cocoon.Device.Orientations.LANDSCAPE_LEFT - Landscape left
     * @property {string} Cocoon.Device.Orientations.LANDSCAPE_RIGHT - Landscape right
     * @property {string} Cocoon.Device.Orientations.LANDSCAPE - Landscape
     * @property {string} Cocoon.Device.Orientations.BOTH - Both
     */
    extension.Orientations = {
        PORTRAIT : 1,
        PORTRAIT_UPSIDE_DOWN : 2,
        LANDSCAPE_LEFT : 4,
        LANDSCAPE_RIGHT : 8,
        LANDSCAPE : 4 | 8,
        BOTH : 1 | 2 | 4 | 8
    };

    /**
     * Enables or disables the auto lock to control if the screen keeps on after an inactivity period.
     * When the auto lock is enabled and the application has no user input for a short period, the system puts the device into a "sleep” state where the screen dims or turns off.
     * When the auto lock is disabled the screen keeps on even when there is no user input for long times.
     * @function autoLock
     * @name autoLock
     * @memberof Cocoon.Device
     * @param {Bool} enabled A boolean value that controls whether to enable or disable the auto lock.
     * @example
     * Cocoon.Device.autoLock(false);
     */
    extension.autoLock = function (enabled) {
        if (Cocoon.nativeAvailable) {
            return Cocoon.callNative("IDTK_APP", "setAutoLockEnabled", arguments);
        }
    };

    return extension;

});;Cocoon.define("Cocoon.Motion" , function(extension){
    "use strict";
    /**
    * All functions related to the Accelerometer and Gyroscope.
    * @namespace Cocoon.Motion
    */
    extension.nativeAvailable = Cocoon.nativeAvailable;

    /**
     * Setups the update interval in seconds (1 second / X frames) to receive the accelerometer updates.
     * It defines the rate at which the devicemotion events are updated.
     * @function setAccelerometerInterval
     * @memberOf Cocoon.Motion
     * @param {number} seconds The update interval in seconds to be set.
     * @example
     * Cocoon.Motion.setAccelerometerInterval(2);
     */
    extension.setAccelerometerInterval = function (updateIntervalInSeconds) {
        if (Cocoon.Motion.nativeAvailable) {
            return window.ext.IDTK_APP.makeCall("setAccelerometerUpdateIntervalInSeconds", updateIntervalInSeconds);
        }
    };

    /**
     * Returns the update interval in seconds that is currently set for accelerometer related events.
     * @function getAccelerometerInterval
     * @memberOf Cocoon.Motion
     * @return {number} The update interval in seconds that is currently set for accelerometer related events.
     * @example
     * console.log(Cocoon.Motion.getAccelerometerInterval());
     */
    extension.getAccelerometerInterval = function () {
        if (Cocoon.Motion.nativeAvailable) {
            return window.ext.IDTK_APP.makeCall("getAccelerometerUpdateIntervalInSeconds");
        }
    };

    /**
     * Setups the update interval in seconds (1 second / X frames) to receive the gyroscope updates.
     * It defines the rate at which the devicemotion and deviceorientation events are updated.
     * @function setGyroscopeInterval
     * @memberOf Cocoon.Motion
     * @param {number} seconds The update interval in seconds to be set.
     * @example
     * Cocoon.Motion.setGyroscopeInterval(2);
     */
    extension.setGyroscopeInterval = function (updateIntervalInSeconds) {
        if (Cocoon.Motion.nativeAvailable) {
            return window.ext.IDTK_APP.makeCall("setGyroscopeUpdateIntervalInSeconds", updateIntervalInSeconds);
        }
    };

    /**
     * Returns the update interval in seconds that is currently set for gyroscope related events.
     * @function getGyroscopeInterval
     * @memberOf Cocoon.Motion
     * @return {number} The update interval in seconds that is currently set for gyroscope related events.
     * @example
     * console.log(Cocoon.Motion.getGyroscopeInterval());
     */
    extension.getGyroscopeInterval = function () {
        if (Cocoon.Motion.nativeAvailable) {
            window.ext.IDTK_APP.makeCall("getGyroscopeUpdateIntervalInSeconds");
        }
    };

    return extension;

});;/**
* The "Cocoon.Touch" object holds some functions to handle the touch events in both surfaces ( Cocoon & WebView )
* @namespace Cocoon.Touch
*/
Cocoon.define("Cocoon.Touch" , function(extension){

    extension.addADivToDisableInput = function() {
        var div = document.createElement("div");
        div.id = "CocoonJSInputBlockingDiv";
        div.style.left = 0;
        div.style.top = 0;
        div.style.width = "100%";
        div.style.height = "100%";
        div.style.position = "absolute";
        div.style.backgroundColor = 'transparent';
        div.style.border = "0px solid #000"; 
        div.style.zIndex = 999999999;
        document.body.appendChild(div);
    };

    extension.removeTheDivToEnableInput = function() {
        var div = document.getElementById("CocoonJSInputBlockingDiv");
        if (div) document.body.removeChild(div);
    };

    /**
     * Disables the touch events in the Cocoon environment.
     * @memberOf Cocoon.Touch
     * @function disable
     * @example
     * Cocoon.Touch.disable();
     */
    extension.disable = function () {
        if (Cocoon.nativeAvailable) {
            window.ext.IDTK_APP.makeCall("disableTouchLayer", "CocoonJSView");
        }
        else if (!navigator.isCocoonJS) {
            if (!Cocoon.App.EmulatedWebViewIFrame) {
                Cocoon.App.forwardEventsToCocoonJSEnabled = false;
                Cocoon.App.forwardAsync("Cocoon && Cocoon.Touch && Cocoon.Touch.disable();");
            }
        }
    };

    /**
     * Enables the touch events in the Cocoon environment.
     * @memberOf Cocoon.Touch
     * @function enable
     * @example
     * Cocoon.Touch.enable();
     */
    extension.enable = function () {
        if (Cocoon.nativeAvailable) {
            window.ext.IDTK_APP.makeCall("enableTouchLayer", "CocoonJSView");
        }
        else if (!navigator.isCocoonJS) {
            if (!Cocoon.App.EmulatedWebViewIFrame) {
                Cocoon.App.forwardEventsToCocoonJSEnabled = true;
                Cocoon.App.forwardAsync("Cocoon && Cocoon.Touch && Cocoon.Touch.enable();");
            }
        }
    };


    /**
     * Disables the touch events in the WebView environment.
     * @memberOf Cocoon.Touch
     * @function disableInWebView
     * @example
     * Cocoon.Touch.disableInWebView();
     */
    extension.disableInWebView = function () {
        if (Cocoon.nativeAvailable) {
            window.ext.IDTK_APP.makeCall("disableTouchLayer", "WebView");
        }
        else if (!navigator.isCocoonJS) {
            if (!Cocoon.App.EmulatedWebViewIFrame) {
                Cocoon.Touch.addADivToDisableInput();
            }
            else {
                Cocoon.App.forwardAsync("Cocoon && Cocoon.Touch && Cocoon.Touch.disableInWebView();");
            }
        }
    };

    /**
     * Enables the touch events in the WebView environment.
     * @memberOf Cocoon.Touch
     * @function enableInWebView
     * @example
     * Cocoon.Touch.enableInWebView();
     */
    extension.enableInWebView = function () {
        if (Cocoon.nativeAvailable) {
            window.ext.IDTK_APP.makeCall("enableTouchLayer", "WebView");
        }
        else if (!navigator.isCocoonJS) {
            if (!Cocoon.App.EmulatedWebViewIFrame) {
                Cocoon.Touch.removeTheDivToEnableInput();
            }
            else {
                Cocoon.Touch.forwardAsync("Cocoon && Cocoon.Touch && Cocoon.Touch.enableInWebView();");
            }
        }
    };
    
    return extension;

});;/** 
* This namespace holds the WebDialog widget, which essentially shows a Webview on top of the CocoonJS layer.
* @namespace Cocoon.Widget
*/
Cocoon.define("Cocoon.Widget" , function(extension){
    "use strict";
    /**
    * Creates the WebDialog
    * @constructor WebDialog
    * @memberOf Cocoon.Widget
    * @example var dialog = new Cocoon.Widget.WebDialog();
    */
    extension.WebDialog = function() {
        
        if (Cocoon.App.nativeAvailable) {
            this.webDialogID = window.ext.IDTK_APP.makeCall("createWebDialog");
        }
        else {
            var iframe = document.createElement("iframe");
            iframe.id = "CocoonJSWebDialogIFrame";
            iframe.name = "CocoonJSWebDialogIFrame";
            iframe.style.cssText = "position:fixed;left:0;top:0;bottom:0;right:0; width:100%; height:100%;margin:0;padding:0;";
            var me = this;
            iframe.onload = function(){
                me.iframeloaded = true;
                var js = "Cocoon = {}; Cocoon.Widget = {}; Cocoon.Widget.WebDialog = {} Cocoon.Widget.WebDialog.close = function()" +
                    "{" +
                    "   window.parent.CocoonJSCloseWebDialog();" +
                    "};";
                me.evalIframe(js);
                for (var i = 0; i < me.pendingEvals.length; ++i) {
                    me.evalIframe(me.pendingEvals[i]);
                }
                me.pendingEvals = [];
            }
            iframe.onerror = function(){
                me.close();
            }
            this.iframe = iframe;
            this.pendingEvals = [];

            window.CocoonJSCloseWebDialog = function() {
               me.close();
            }
        }

    }

    extension.WebDialog.prototype = {
        /**
        * Shows the dialog.
        * @function show
        * @memberOf Cocoon.Widget.WebDialog
        * @param {string} url The url to be opened on the Web Dialog.
        * @param {function} closeCallback The callback that will be fired when the dialog is closed.
        * @example 
        * var dialog = new Cocoon.Widget.WebDialog();
        * dialog.show("http://www.ludei.com", function(){
        *   console.log("The dialog has been closed!");
        * });
        */
        show: function(url, callback) {
            this.closeCallback = function() {
                Cocoon.Touch.enable();
                if (callback)
                    callback();
            }
            if (Cocoon.App.nativeAvailable) {
                Cocoon.Touch.disable();
                return window.ext.IDTK_APP.makeCallAsync("showWebDialog", this.webDialogID, url, this.closeCallback);
            }
            else {
                this.iframe.src = url;
                document.body.appendChild(this.iframe);
            }

        },
        
        /**
        * Closes the dialog.
        * @function close
        * @memberOf Cocoon.Widget.WebDialog
        * @example 
        * var dialog = new Cocoon.Widget.WebDialog();
        * dialog.show("http://www.ludei.com");
        * //This dialog will close after 15 seconds.
        * setTimeout(function(){
        *   dialog.close();
        * }, 15000);
        */
        close: function() {
            if (Cocoon.App.nativeAvailable) {
                return window.ext.IDTK_APP.makeCallAsync("closeWebDialog", this.webDialogID);
            }
            else {
                if (this.iframe.parentNode) {
                    this.iframe.parentNode.removeChild(this.iframe);
                }
            }
            if (this.closeCallback)
                this.closeCallback();
        },
        evalIframe: function(js) {
            window.frames["CocoonJSWebDialogIFrame"].eval(js);
        },

        /**
        * Evaluates a javascript string in the WebDialog environment.
        * @function eval
        * @memberOf Cocoon.Widget.WebDialog
        * @example 
        * var dialog = new Cocoon.Widget.WebDialog();
        * dialog.eval("alert('Michael Jackson is the king of pop')");
        */
        eval: function(js) {
            if (Cocoon.App.nativeAvailable) {
                return window.ext.IDTK_APP.makeCallAsync("evalWebDialog", this.webDialogID, js);
            }
            else {
                if (this.iframeloaded)
                    this.evalIframe(js);
                else
                    this.pendingEvals.push(js);
            }
        }

    };

    return extension;

});;Cocoon.define("Cocoon.Camera" , function(extension) {

    /**
    * This namespace represents the CocoonJS camera extension API.
    *
    * <div class="alert alert-success">
	*   Here you will find a demo about this namespace: <a href="https://github.com/ludei/cocoonjs-demos/tree/master/Camera/videopuzzle">Videopuzzle demo</a>.
	*</div>
    *   
    * @namespace Cocoon.Camera
    * @example
    * Cocoon.Camera.start({
    * success : function(stream){
    *     ctx.fillRect(0, 0, w, h);
    *     ctx.drawImage(stream, 0, 0, w, h);
    * },
    * error : function(){
    *   console.log("Error", arguments);
    * }
    * });
    */

    navigator.getUserMedia_ = ( navigator.getUserMedia ||
                                navigator.webkitGetUserMedia ||
                                navigator.mozGetUserMedia ||
                                navigator.msGetUserMedia);
    
    /**
    * 
    * @namespace 
    */

    /**
     * The predefined possible camera types.
     * @memberof Cocoon.Camera
     * @name Cocoon.Camera.CameraType
     * @property {object} Cocoon.Camera.CameraType - The object itself
     * @property {string} Cocoon.Camera.CameraType.FRONT - Represents the front camera on the device.
     * @property {string} Cocoon.Camera.CameraType.BACK - Represents the back camera on the device.
     */
	extension.CameraType = {
	    FRONT : "FRONT",
	    BACK : "BACK"
	};

    /**
     * The predefined possible camera video capturing image format types.
     * @memberof Cocoon.Camera
     * @name Cocoon.Camera.CaptureFormatType
     * @property {string} Cocoon.Camera.CaptureFormatType - The object itself
     * @property {string} Cocoon.Camera.CaptureFormatType.JPEG 
     * @property {string} Cocoon.Camera.CaptureFormatType.RGB_565 
     * @property {string} Cocoon.Camera.CaptureFormatType.NV21 
     * @property {string} Cocoon.Camera.CaptureFormatType.NV16 
     * @property {string} Cocoon.Camera.CaptureFormatType.YUY2 
     * @property {string} Cocoon.Camera.CaptureFormatType.YV12 
     * @property {string} Cocoon.Camera.CaptureFormatType.BGRA32 
     */
	extension.CaptureFormatType = {
	    JPEG : "JPEG",
	    RGB_565 : "RGB_565",
	    NV21 : "NV21", 
	    NV16 : "NV16",
	    YUY2 : "YUY2",
	    YV12 : "YV12",
	    BGRA32 : "32BGRA"
	};

	/**
     * The object that represents the information of a camera. It includes all the information to be able to setup a camera to capture video or to take pictures.
     * @memberof Cocoon.Camera
     * @name Cocoon.Camera.CameraInfo
     * @property {string} Cocoon.Camera.CameraInfo - The object itself
     * @property {string} Cocoon.Camera.CameraInfo.cameraIndex The index of the camera.
     * @property {Cocoon.Camera.CameraType} Cocoon.Camera.CameraType The type of the camera among the possible values in {@link Cocoon.Camera.CameraType}.
     * @property {string} Cocoon.Camera.CameraInfo.supportedVideoSizes An array of {@link Cocoon.Size} values that represent the supported video sizes for the camera.
     * @property {string} Cocoon.Camera.CameraInfo.supportedVideoFrameRates An array of numbers that represent the supported video frame rates for the camera.
     * @property {string} Cocoon.Camera.CameraInfo.supportedImageFormats An array of {@link Cocoon.Camera.CaptureFormatType} values that represent the supported video format types for the camera.
     */
	extension.CameraInfo =  {

		cameraIndex : 0,

		cameraType : extension.CameraType.BACK,

		supportedVideoSizes : [],

		supportedVideoFrameRates : [],

		supportedVideoCaptureImageFormats : []
	};

	/**
	* Returns the number of available camera in the platform/device.
	* @memberof Cocoon.Camera
	* @function getNumberOfCameras
	* @returns {number} The number of cameras available in the platform/device.
	* @example
	* console.log(Cocoon.Camera.getNumberOfCameras());
	*/
	extension.getNumberOfCameras = function()
	{
		if (Cocoon.nativeAvailable && navigator.isCocoonJS)
		{
			return Cocoon.callNative("IDTK_SRV_CAMERA", "getNumberOfCameras", arguments);
		}else{
			return (navigator.getUserMedia_) ? 1 : 0;
		}
	};

	/**
	* Returns an array of {@link Cocoon.Camera.CameraInfo} objects representing all the information of all the cameras available in the platform/device.
	* @memberof Cocoon.Camera
	* @function getAllCamerasInfo
	* @returns {Array} An array of {@link Cocoon.Camera.CameraInfo} objects.
	* @example
	* console.log(JSON.stringify(Cocoon.Camera.getAllCamerasInfo()));
	*/
	extension.getAllCamerasInfo = function()
	{
		if (Cocoon.nativeAvailable && navigator.isCocoonJS)
		{
			return Cocoon.callNative("IDTK_SRV_CAMERA", "getAllCamerasInfo", arguments);
		}
	};

	/**
	* Returns the {@link Cocoon.Camera.CameraInfo} object that represents all the information of the specified camera index in the platform/device.
	* @memberof Cocoon.Camera
	* @function getCameraInfoByIndex
	* @param {number} cameraIndex The index of the camera to get the info from. The index should be between 0 and N (Being N the value returned by {@link Cocoon.Camera.getNumberOfCameras}).
	* @returns {Cocoon.Camera.CameraInfo} The {@link Cocoon.Camera.CameraInfo} of the given camera index.
	* @example
	* console.log(JSON.stringify(Cocoon.Camera.getCameraInfoByIndex(0)));
	*/
	extension.getCameraInfoByIndex = function(cameraIndex)
	{
		if (Cocoon.nativeAvailable && navigator.isCocoonJS)
		{
			return Cocoon.callNative("IDTK_SRV_CAMERA", "getCameraInfoByIndex", arguments);
		}
	};

	/**
	* Returns the {@link Cocoon.Camera.CameraInfo} object that represents all the information of the first camera of the specified type found in the platform/device.
	* @memberof Cocoon.Camera
	* @function getCameraInfoByType
	* @param {Cocoon.Camera.CameraType} cameraType The type of the camera to get the info from. 
	* @returns {Cocoon.Camera.CameraInfo} The {@link Cocoon.Camera.CameraInfo} of the first camera of the given camera type that has been found in the platform/device.
	*/
	extension.getCameraInfoByType = function(cameraType)
	{
		if (Cocoon.nativeAvailable && navigator.isCocoonJS)
		{
			return Cocoon.callNative("IDTK_SRV_CAMERA", "getCameraInfoByType", arguments);
		}
	};
	
	/**
	* Starts a camera to capture video. The developer must specify at least the index of the camera to be used. Some other setup parameters can also be passed to control the video capture. An image object
	* that will be automatically updated with the captured frames is returned so the developer just need to draw the image in every frame. A null image object is returned if the setup did not work or there is
	* no available camera.
	* @memberof Cocoon.Camera
	* @function start
	* @param {object} params - The object itself
	* @param {number} params.cameraIndex The index of the camera to start video capture with.
	* @param {number} params.captureWidth The hozirontal size of the video capture resolution. If the value does not correspond to any of the sizes supported by the camera, the closest one is used. See {@link Cocoon.Camera.CameraInfo}.
	* If no value is given, the maximum size available is used.
	* @param {number} params.captureHeight The vertical size of the video capture resolution. If value does not correspond to any of the sizes supported by the camera, the closest one is used. See {@link Cocoon.Camera.CameraInfo}.
	* If no value is given, the maximum size available is used.
	* @param {number} params.captureFrameRate The frame rate to capture the video at. If the value does not correspond to any of the frame rates supported by the camera, the closest one is used. See {@link Cocoon.Camera.CameraInfo}.
	* If no value is given, the maximum frame rate available is used.
	* @param {value} params.captureImageFormat A value from the available {@link Cocoon.Camera.CaptureFormatType} formats to specify the format of the images that will be captured. See {@link Cocoon.Camera.CameraInfo}.
	* If no value is given, the first available capture image format is used.
	* @returns {image} An image object that will automatically update itself with the captured frames or null if the camera capture could not start.
	* @example
	* 	Cocoon.Camera.start({
	* 	  success : function(stream){
	* 	      ctx.fillRect(0, 0, w, h);
	* 	      ctx.drawImage(stream, 0, 0, w, h);
	* 	  },
	* 	  error : function(){
	* 	    console.log("Error", arguments);
	* 	  }
	* 	});
	*/
	extension.start = function(params) {

		if( !((Boolean(params.success)) && (Boolean(params.error))) ) throw new Error("Missing callbacks for Cocoon.Camera.start();");

		if (Cocoon.nativeAvailable)
		{
			var properties = {
				cameraIndex : 0, 
				width : 50, 
				height : 50,
				frameRate : 25
			};

			var args = Cocoon.clone(properties,params);
			var img = Cocoon.callNative("IDTK_SRV_CAMERA", "startCapturing", args);
			
			if(Boolean(img)) { params.success(img); }else{ params.error(false); }
            
		}else{
			navigator.getUserMedia_( {
              video:true, audio:false
            },    
            function(stream) {
                params.success(stream);
            },
            function(error) {
                params.error(error);
            });

		}
	};

	/**
	* Stops a camera that is already started capturing video.
	* @memberof Cocoon.Camera
	* @function stop
	* @param cameraIndex The index of the camera to stop capturing video.
	*/
	extension.stop = function(cameraIndex)
	{
		if (Cocoon.nativeAvailable && navigator.isCocoonJS)
		{
			return Cocoon.callNative("IDTK_SRV_CAMERA", "stopCapturing", arguments);
		}
	};

	/**
	* Indicates if a camera is capturing video or not.
	* @memberof Cocoon.Camera
	* @function isCapturing
	* @param cameraIndex The index of the camera to check if is capturing video or not.
	* @returns {boolean} A flag indicating if the given camera (by index) is capturing video (true) or not (false).
	*/
	extension.isCapturing = function(cameraIndex)
	{
		if (Cocoon.nativeAvailable && navigator.isCocoonJS)
		{
			return Cocoon.callNative("IDTK_SRV_CAMERA", "isCapturing", arguments);
		}
	};

	return extension;
});;Cocoon.define("Cocoon.Ad" , function(extension){
    "use strict";

    /**
    * This namespace represents the Cocoon Advertisement extension API.
    *
    * <div class="alert alert-success">
	*   Here you will find a demo about this namespace: <a href="https://github.com/ludei/cocoonjs-demos/tree/master/Ads">Ads demo</a>.
	*</div>
    *
	* <div class="alert alert-warning">
	*    <strong>Warning!</strong> This JavaScript extension requires some configuration parameters on the <a href="https://ludei.zendesk.com/hc/en-us">cloud compiler</a>!
	* </div>
    * @namespace Cocoon.Ad
    * @example
    * // This example shows how to integrate ads in your game
    * Cocoon.Ad.banner.on("shown" , function(){
    * 	console.log("Banner shown!");
    * });
    * Cocoon.Ad.banner.on("ready" , function(){
    * 	Cocoon.Ad.setBannerLayout(Cocoon.Ad.BannerLayout.BOTTOM_CENTER);
    * 	Cocoon.Ad.showBanner();
    * });
    * Cocoon.Ad.banner.on("hidden" , function(){
    * 	console.log("Banner hidden!");
    * });
    * // Fetch a banner, the above callbacks will handle it.
    * Cocoon.Ad.loadBanner();
    */

    extension.nativeAvailable = (!!Cocoon.nativeAvailable) && (!!window.ext.IDTK_SRV_AD);

    /**
    * The predefined possible layouts for a banner ad.
	* @name Cocoon.Ad.BannerLayout
	* @memberOf Cocoon.Ad
	* @property {string} TOP_CENTER  Specifies that the banner must be shown in the top of the screen and vertically centered.
	* @property {string} BOTTOM_CENTER  Specifies that the banner must be shown in the bottom of the screen and vertically centered.
	*/
	extension.BannerLayout = 
	{

	    TOP_CENTER      : "TOP_CENTER",

	    BOTTOM_CENTER   : "BOTTOM_CENTER"
	};
	
	/**
    * A rectangle object that contains the banner dimensions
	* @memberOf Cocoon.Ad
	* @function Rectangle
	* @private
	* @param {number} x The top lef x coordinate of the rectangle
	* @param {number} y The top lef y coordinate of the rectangle
	* @param {number} width The rectangle width
	* @param {number} height The rectangle height
	* @example
	* var rect = new Cocoon.Ad.Rectangle(0,0,300,300);
	*/
	extension.Rectangle = function(x, y, width, height) 
	{
	
	    this.x = x;

	    this.y = y;

	    this.width = width;

	    this.height = height;
	};

	extension.Banner = function(id)
	{
		if (typeof id !== 'number') throw "The given ad ID is not a number.";

		this.id = id;
		var me = this;

		this.onBannerShown = new Cocoon.EventHandler("IDTK_SRV_AD", "Ad", "onbannershow", function(sourceListener, args)
    	{
    		if (me.id === args[0]) 
    		{
    			sourceListener();
    		}
    	});

		this.onBannerHidden = new Cocoon.EventHandler("IDTK_SRV_AD", "Ad", "onbannerhide", function(sourceListener, args)
    	{
    		if (me.id === args[0]) 
    		{
    			sourceListener();
    		}
    	});

		this.onBannerReady = new Cocoon.EventHandler("IDTK_SRV_AD", "Ad", "onbannerready", function(sourceListener, args)
    	{
    		if (me.id === args[0]) 
    		{
    			sourceListener(args[1], args[2]);
    		}
    	});

    	var signal = new Cocoon.Signal.createSignal();

		signal.register("ready", this.onBannerReady);

		signal.register("shown", this.onBannerShown);

		signal.register("hidden", this.onBannerHidden);

		this.on = signal.expose();
	};

	extension.Banner.prototype = {

		showBanner : function()
		{
			if (Cocoon.Ad.nativeAvailable)
			{
				Cocoon.callNative("IDTK_SRV_AD", "showBanner", [this.id], true);
			}
		},

		hideBanner : function()
		{
			if (Cocoon.Ad.nativeAvailable)
			{
				Cocoon.callNative("IDTK_SRV_AD", "hideBanner", [this.id], true);
			}
		},

		load : function()
		{
			if (Cocoon.Ad.nativeAvailable)
			{
				Cocoon.callNative("IDTK_SRV_AD", "refreshBanner", [this.id], true);
			}
		},

		getRectangle : function()
		{
			if (Cocoon.Ad.nativeAvailable)
			{
				return Cocoon.callNative("IDTK_SRV_AD", "getRectangle", [this.id]);
			}
		},

		setRectangle : function(rect)
		{
			if (Cocoon.Ad.nativeAvailable)
			{
				return Cocoon.callNative("IDTK_SRV_AD", "setRectangle", [this.id, rect]);
			}
		},

		setBannerLayout : function(bannerLayout)
		{
			if (Cocoon.Ad.nativeAvailable)
			{
				return Cocoon.callNative("IDTK_SRV_AD", "setBannerLayout", [this.id, bannerLayout]);
			}
		}
	};

	extension.Interstitial = function(id)
	{
		if (typeof id !== 'number') throw "The given ad ID is not a number.";

		this.id = id;
		var me = this;

		this.onFullScreenShown = new Cocoon.EventHandler("IDTK_SRV_AD", "Ad", "onfullscreenshow", function(sourceListener, args)
    	{
    		if (me.id === args[0]) {
    			sourceListener();
    		}
    	});

    	this.onFullScreenHidden = new Cocoon.EventHandler("IDTK_SRV_AD", "Ad", "onfullscreenhide", function(sourceListener, args)
    	{
    		if (me.id === args[0]) {
    			sourceListener();
    		}
    	});

    	this.onFullScreenReady = new Cocoon.EventHandler("IDTK_SRV_AD", "Ad", "onfullscreenready", function(sourceListener, args)
    	{
    		if (me.id === args[0]) {
    			sourceListener();
    		}
    	});

    	var signal = new Cocoon.Signal.createSignal();

		signal.register("ready", this.onFullScreenReady);
		signal.register("shown", this.onFullScreenShown);
		signal.register("hidden", this.onFullScreenHidden);

		this.on = signal.expose();

	};

	extension.Interstitial.prototype = {

		showInterstitial : function()
		{
			if (Cocoon.Ad.nativeAvailable)
			{
				return Cocoon.callNative("IDTK_SRV_AD", "showFullScreen", [this.id], true);
			}
		},

		refreshInterstitial : function()
		{
			if (Cocoon.Ad.nativeAvailable)
			{
				return Cocoon.callNative("IDTK_SRV_AD", "refreshFullScreen", [this.id], true);
			}
		}
	};

	extension.configure = function(parameters)
	{
        if (typeof parameters === "undefined") {
            parameters = {};
        }

		if (Cocoon.Ad.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_AD", "requestInitialization", arguments, true);
		}
	};

	extension.createBanner = function(parameters)
	{
		if (typeof parameters === "undefined") {
            parameters = {};
        }

		if (Cocoon.Ad.nativeAvailable)
		{
			var adId = Cocoon.callNative("IDTK_SRV_AD", "createBanner", [parameters]);
			var banner = new extension.Banner(adId);

			return banner;
		}
	};

	extension.releaseBanner = function(banner)
	{
		if (typeof banner === "undefined") {
            throw "The banner ad object to be released is undefined"
        }

		if (Cocoon.Ad.nativeAvailable)
		{
			Cocoon.callNative("IDTK_SRV_AD", "releaseBanner", [banner.id]);
		}
	};

	extension.createInterstitial = function(parameters)
	{
		if (typeof parameters === "undefined") {
            parameters = {};
        }

		if (Cocoon.Ad.nativeAvailable)
		{
			var adId = Cocoon.callNative("IDTK_SRV_AD", "createFullscreen", [parameters]);
			var fullscreen = new Cocoon.Ad.Interstitial(adId);

			return fullscreen;
		}
	};

	extension.releaseInterstitial = function(fullscreen)
	{
		if (!fullscreen) {
            throw "The fullscreen ad object to be released is undefined"
        }

		if (Cocoon.Ad.nativeAvailable)
		{
			Cocoon.callNative("IDTK_SRV_AD", "releaseFullscreen", [fullscreen.id]);
		}
	};

	/**
    * Shows a banner ad if available.
	* @memberOf Cocoon.Ad
	* @function showBanner
	* @example
	* Cocoon.Ad.showBanner();
	*/
	extension.showBanner = function()
	{
		if (Cocoon.Ad.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_AD", "showBanner", arguments, true);
		}
	};

	/**
    * Hides the banner ad if it was being shown.
	* @memberOf Cocoon.Ad
	* @function hideBanner
	* @example
	* Cocoon.Ad.hideBanner();
	*/
	extension.hideBanner = function()
	{
		if (Cocoon.Ad.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_AD", "hideBanner", arguments, true);
		}
	};

	/**
    * Loads a new banner ad.
	* @memberOf Cocoon.Ad
	* @function refreshBanner
	* @private
	* @example
	* Cocoon.Ad.refreshBanner();
	*/
	extension.refreshBanner = function()
	{
		if (Cocoon.Ad.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_AD", "refreshBanner", arguments, true);
		}
	};

	/**
    * Loads a new interstitial ad.
	* @memberOf Cocoon.Ad
	* @function showInterstitial
	* @example
	* Cocoon.Ad.showInterstitial();
	*/
	extension.showInterstitial = function()
	{
		if (Cocoon.Ad.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_AD", "showFullScreen", arguments, true);
		}
	};

	/**
    * Shows a full screen ad if available.
	* @memberOf Cocoon.Ad
	* @function refreshInterstitial
	* @private
	* @example
	* Cocoon.Ad.refreshInterstitial();
	*/
	extension.refreshInterstitial = function()
	{
		if (Cocoon.Ad.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_AD", "refreshFullScreen", arguments, true);
		}
	};

	/**
    * Makes a request to preload a banner ad.
	* @memberOf Cocoon.Ad
	* @function loadBanner
	* @example
	* Cocoon.Ad.loadBanner();
	*/
	extension.preloadedBanner = false;
	extension.loadBanner = function()
	{
		if (Cocoon.Ad.nativeAvailable){
			if (Cocoon.Ad.preloadedBanner) {
				return Cocoon.Ad.refreshBanner();
			}else{
				Cocoon.Ad.preloadedBanner = true;
				return Cocoon.callNative("IDTK_SRV_AD", "preloadBanner", arguments, true);
			}
		}
	};

	/**
    * Makes a request to load a full screen ad (interstitial).
	* @memberOf Cocoon.Ad
	* @function loadInterstitial
	* @example
	* Cocoon.Ad.loadInterstitial();
	*/
	extension.preloadedInterstitial = false;
	extension.loadInterstitial = function()
	{
		if (Cocoon.Ad.nativeAvailable){
			if (Cocoon.Ad.preloadedInterstitial) {
				return Cocoon.Ad.refreshInterstitial();
			}else{
				Cocoon.Ad.preloadedInterstitial = true;
				return Cocoon.callNative("IDTK_SRV_AD", "preloadFullScreen", arguments, true);
			}
		}
	};

	/**
    * Sets the rectangle where the banner ad is going to be shown.
	* @memberOf Cocoon.Ad
	* @function setRectangle
	* @private
	* @param {Cocoon.Ad.Rectangle} rect The rectangle representing the banner position and domensions.
	* @example
	* Cocoon.Ad.setRectangle();
	*/
	extension.setRectangle = function()
	{
		if (Cocoon.Ad.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_AD", "setRectangle", arguments);
		}
	};

	/**
    * Gets the rectangle representing the banner screen position.
	* @memberOf Cocoon.Ad
	* @private
	* @function getRectangle
	* @example
	* Cocoon.Ad.getRectangle();
	*/
	extension.getRectangle = function()
	{
		if (Cocoon.Ad.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_AD", "getRectangle", arguments);
		}
	};

	/**
    * Sets the rectangle where the banner ad is going to be shown.
	* @memberOf Cocoon.Ad
	* @function setBannerLayout
	* @param {Cocoon.Ad.BannerLayout} bannerLayout The layout where the bannerwill be placed.
	* @example
	* Cocoon.Ad.load();
	*/
	extension.setBannerLayout = function(bannerLayout)
	{
		if (Cocoon.Ad.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_AD", "setBannerLayout", arguments);
		}
	};

	extension.onBannerShown = new Cocoon.EventHandler("IDTK_SRV_AD", "Ad", "onbannershow");

	extension.onBannerHidden = new Cocoon.EventHandler("IDTK_SRV_AD", "Ad", "onbannerhide"); 

	extension.onBannerReady = new Cocoon.EventHandler("IDTK_SRV_AD", "Ad", "onbannerready"); 

	extension.onFullScreenShown = new Cocoon.EventHandler("IDTK_SRV_AD", "Ad", "onfullscreenshow"); 

	extension.onFullScreenHidden = new Cocoon.EventHandler("IDTK_SRV_AD", "Ad", "onfullscreenhide");

	extension.onFullScreenReady = new Cocoon.EventHandler("IDTK_SRV_AD", "Ad", "onfullscreenready"); 

	var signal = new Cocoon.Signal.createSignal();

	/**
     * Allows to listen to events called when a banner is ready.
     * @event On banner ready
     * @memberof Cocoon.Ad
     * @example
     * Cocoon.Ad.banner.on("ready", function(){
     *  ...
     * });
     */
	signal.register("ready", extension.onBannerReady);
	/**
     * Allows to listen to events called when a banner is shown.
     * @event On banner shown
     * @memberof Cocoon.Ad
     * @example
     * Cocoon.Ad.banner.on("shown", function(){
     *  ...
     * });
     */
	signal.register("shown", extension.onBannerShown);
	/**
     * Allows to listen to events called when a banner is hidden.
     * @event On banner hidden
     * @memberof Cocoon.Ad
     * @example
     * Cocoon.Ad.banner.on("hidden", function(){
     *  ...
     * });
     */
	signal.register("hidden", extension.onBannerHidden);

	extension.banner = {};
	extension.banner.on = signal.expose();

	var signal = new Cocoon.Signal.createSignal();

	/**
     * Allows to listen to events called when a full screen ad is ready.
     * @event On interstitial ready
     * @memberof Cocoon.Ad
     * @example
     * Cocoon.Ad.interstitial.on("ready", function(){
     *  ...
     * });
     */
	signal.register("ready", extension.onFullScreenReady);
	/**
     * Allows to listen to events called when a full screen ad is shown.
     * @event On interstitial shown
     * @memberof Cocoon.Ad
     * @example
     * Cocoon.Ad.interstitial.on("shown", function(){
     *  ...
     * });
     */
	signal.register("shown", extension.onFullScreenShown);
	/**
     * Allows to listen to events called when a full screen ad is hidden.
     * @event On interstitial hidden
     * @memberof Cocoon.Ad
     * @example
     * Cocoon.Ad.interstitial.on("hidden", function(){
     *  ...
     * });
     */
	signal.register("hidden", extension.onFullScreenHidden);
	
	extension.interstitial = {};
	extension.interstitial.on = signal.expose();

	return extension;
});;Cocoon.define("Cocoon.Store" , function(extension){
    "use strict";

    /**
    * This namespace represents the In-app purchases extension API.
    * <div class="alert alert-success">
	*   Here you will find a demo about this namespace: <a href="https://github.com/ludei/cocoonjs-demos/tree/master/Store-skeleton">Store-skeleton demo</a>.
	*</div>
	*
    * <div class="alert alert-warning">
	*    <strong>Warning!</strong> This JavaScript extension requires some configuration parameters on the <a href="https://ludei.zendesk.com/hc/en-us">cloud compiler</a>!
	* </div>
    * @namespace Cocoon.Store
    * @example
    * // Basic usage, register callbacks first
	* Cocoon.Store.on("purchase",{
	* 	started: function(){ ... },
	* 	success: function(purchaseInfo){ console.log( JSON.stringify(purchaseInfo) ) },
	* 	error: function(productId, err){ ... }
	* });
    * Cocoon.Store.on("load",{
	* 	started: function(){ ... },
	*	success: function(products){
    *		for (var i = 0; i < products.length; i++) {
    *			Cocoon.Store.addProduct(products[i]);
    *			console.log("Adding product to the local database: " + JSON.stringify(products[i]));
    *		};
    *	},
	* 	error: function(errorMessage){ ... }
	* });
	* // Initialize store service
	* Cocoon.Store.initialize({
	*     sandbox: false,
	*     managed: true
	* });
	* // Fetch the products from the store
	* // The callbacks for this event are set in the Cocoon.Store.on("load"); event handler.
    * Cocoon.Store.loadProducts(["magic.sword", "health.potion"]);
    */

    extension.nativeAvailable = (!!Cocoon.nativeAvailable) && (!!window.ext.IDTK_SRV_STORE);

	/**
	* The object that represents the information of a product in the store.
	* @memberof Cocoon.Store
	* @name Cocoon.Store.ProductInfo
	* @property {object} Cocoon.Store.ProductInfo - The object itself
	* @property {string} Cocoon.Store.ProductInfo.productId The id of the product.
	* @property {string} Cocoon.Store.ProductInfo.productAlias The alias of the product.
	* @property {Cocoon.Store.ProductType} Cocoon.Store.ProductInfo.productType The product type.
	* @property {string} Cocoon.Store.ProductInfo.title The title of the product.
	* @property {string} Cocoon.Store.ProductInfo.description The description of the product.
	* @property {string} Cocoon.Store.ProductInfo.price The price of the product.
	* @property {string} Cocoon.Store.ProductInfo.localizedPrice The localized price of the product.
	* @property {string} Cocoon.Store.ProductInfo.downloadURL The URL of the asset to be downloaded for this purchase.
	*/
	extension.ProductInfo = {

		productId : "productId",

		productAlias : "productAlias",

		productType : "productType",

		title : "title",

		description : "description",

		price : "price",

		localizedPrice : "localizedPrice",

		downloadURL : "downloadURL"
	};

	/**
	* The predefined possible states of product types.
	* @memberof Cocoon.Store
	* @name Cocoon.Store.ProductType
	* @property {object} Cocoon.Store.ProductType - The object itself
	* @property {string} Cocoon.Store.ProductType.CONSUMABLE A consumable product. See platform documentation for further information.
	* @property {string} Cocoon.Store.ProductType.NON_CONSUMABLE See platform documentation for further information.
	* @property {string} Cocoon.Store.ProductType.AUTO_RENEWABLE_SUBSCRIPTION An auto-renewable subscription. See platform documentation for further information.
	* @property {string} Cocoon.Store.ProductType.FREE_SUBSCRIPTION A free subscription. See platform documentation for further information.
	* @property {string} Cocoon.Store.ProductType.NON_RENEWABLE_SUBSCRIPTION A non-renewable subscription. See platform documentation for further information.
	*/
	extension.ProductType = 
	{

	    CONSUMABLE : 0,

	    NON_CONSUMABLE : 1,

	    AUTO_RENEWABLE_SUBSCRIPTION : 2,

	    FREE_SUBSCRIPTION : 3,

	    NON_RENEWABLE_SUBSCRIPTION : 4
	};

	/**
	* The predefined possible store types.
	* @memberof Cocoon.Store
	* @name Cocoon.Store.StoreType
	* @property {object} Cocoon.Store.StoreType - The object itself
	* @property {string} Cocoon.Store.StoreType.APP_STORE Apple AppStore.
	* @property {string} Cocoon.Store.StoreType.PLAY_STORE Android Play Store.
	* @property {string} Cocoon.Store.StoreType.MOCK_STORE Mock Store (Used for testing).
	* @property {string} Cocoon.Store.StoreType.CHROME_STORE Chrome AppStore.
	* @property {string} Cocoon.Store.StoreType.AMAZON_STORE Amazon AppStore.
	* @property {string} Cocoon.Store.StoreType.NOOK_STORE Nook Store.
	*/
	extension.StoreType = 
	{

	    APP_STORE : 0,

	    PLAY_STORE : 1,

		MOCK_STORE : 2,

	    CHROME_STORE : 3,

	    AMAZON_STORE : 4,

	    NOOK_STORE : 5
	};

	/**
	* The object that represents the information of a purchase.
	* @memberof Cocoon.Store
	* @name Cocoon.Store.PurchaseInfo
	* @property {object} Cocoon.Store.PurchaseInfo - The object itself
	* @property {string} Cocoon.Store.PurchaseInfo.transactionId The transaction id of a purchase.
	* @property {string} Cocoon.Store.PurchaseInfo.purchaseTime The time when the purchase was done in seconds since 1970.
	* @property {Cocoon.Store.PurchaseState} Cocoon.Store.PurchaseInfo.purchaseState The state of the purchase.
	* @property {string} Cocoon.Store.PurchaseInfo.productId The product id related to this purchase.
	* @property {string} Cocoon.Store.PurchaseInfo.quantity The number of products of the productId kind purchased in this transaction.
	*/
	extension.PurchaseInfo = function(transactionId, purchaseTime, purchaseState, productId, quantity)
	{

		this.transactionId = transactionId;

		this.purchaseTime = purchaseTime;

		this.purchaseState = purchaseState;

		this.productId = productId;

		this.quantity = quantity;

		return this;
	};

	/**
    * The predefined possible states of a purchase.
	* @memberof Cocoon.Store
	* @name Cocoon.Store.PurchaseState
	* @property {object} Cocoon.Store.PurchaseState - The object itself
	* @property {string} Cocoon.Store.PurchaseState.PURCHASED The product has been successfully purchased. The transaction has ended successfully.
	* @property {string} Cocoon.Store.PurchaseState.CANCELED The purchase has been canceled.
	* @property {string} Cocoon.Store.PurchaseState.REFUNDED The purchase has been refunded.
	* @property {string} Cocoon.Store.PurchaseState.EXPIRED The purchase (subscriptions only) has expired and is no longer valid.
    */
	extension.PurchaseState = 
	{

	    PURCHASED : 0,

	    CANCELED : 1,

	    REFUNDED : 2,

	    EXPIRED : 3
	};

	/**
	* Gets the name of the native store implementation. 
	* @memberof Cocoon.Store
	* @function getStoreType
	* @returns {Cocoon.Store.StoreType} The store type.
	* @example
	* console.log(Cocoon.Store.getStoreType());
	*/
	extension.getStoreType = function()
	{
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "getStoreType", arguments);
		}else{
			return false;
		}
	};

	/**
	* Starts the Store Service. This will make the system to initialize the 
	* Store Service and probably Store callbacks will start to be received 
	* after calling this method. Because of this, you should have set your event handler 
	* before calling this method, so you don't lose any callback.
	* @memberof Cocoon.Store
	* @function initialize
	* @example
	* Cocoon.Store.initialize();
	*/
	extension.initialize = function(params){
		
		params = params || {};

		var properties = {
            sandbox : false,
            managed : true
        };

        var args = Cocoon.clone(properties,params);

		Cocoon.Store.requestInitialization({ 
			sandbox: args[0],
			managed: args[1]
		});
		
		Cocoon.Store.start();
	}

	/**
	* @memberof Cocoon.Store
	* @function requestInitialization
	* @private
	*/
	extension.requestInitialization = function(parameters) {
        if (typeof parameters === "undefined") 
        {
            parameters = {};
        }
        else
        {
        	if (parameters['managed'] !== undefined) parameters['remote'] = parameters['managed'];
        	if (parameters['sandbox'] !== undefined) parameters['debug'] = parameters['sandbox'];
        }

		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "requestInitialization", arguments, true);
		}
	};

	/**
	* @memberof Cocoon.Store
	* @function start
	* @private
	*/
	extension.start = function() {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "start", arguments);
		}
	};

	/**
	* This method allows you to check is the  Store service is available in this platform. 
	* Not all iOS and Android devices will have the Store service 
	* available so you should check if it is before calling any other method.
	* @memberof Cocoon.Store
	* @function canPurchase
	* @returns {boolean} True if the service is available and false otherwise.
	*/
	extension.canPurchase = function() {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "canPurchase", arguments);
		}else{
			return false;
		}
	};

	/**
	* Fetches the products from the CocoonJS Cloud Compiling service store configuration. 
	* The request is monitored using the "load" signal events.
	* @memberof Cocoon.Store
	* @function fetchProductsFromServer
	* @private
	* @example
	* // First register callbacks
    * Cocoon.Store.on("load",{
    * 	started: function(){ ... },
    * 	success: function(products){ ... },
    * 	error: function(errorMessage){ ... }
    * });
    * // Then call the fetch method
    * Cocoon.Store.fetchProductsFromServer();
	*/
	extension.fetchProductsFromServer = function() {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "fetchProductsFromServer", arguments, true);
		}
	};

	/**
	* Fetches the products information from the Store. 
	* The request is monitored using the "load" signal events.
	* @memberof Cocoon.Store
	* @function loadProducts
	* @example
	* // First register callbacks
    * Cocoon.Store.on("load",{
    * 	started: function(){ ... },
    * 	success: function(products){ ... },
    * 	error: function(errorMessage){ ... }
    * });
    * // Then call the fetch method
    * Cocoon.Store.loadProducts(["magic.sword", "health.potion"]);
	*/
	extension.loadProducts = function(productIds) {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "fetchProductsFromStore", arguments, true);
		}
	};

	/**
	* Finishes a purchase transaction and removes the transaction from the transaction queue. 
	* This method must be called after a purchase finishes successfully and the "success" 
	* event inside of the "on purchase products" callback has been received. 
	* If the purchase includes some asset to download from an external server this method must be called after the asset has been successfully downloaded. 
	* If you do not finish the transaction because the asset has not been correctly downloaded the {@link Cocoon.Store.onProductPurchaseStarted} method will be called again later on.
	* @memberof Cocoon.Store
	* @function finish
	* @param {string} transactionId The transactionId of the purchase to finish.
	*/ 
	extension.finish = function(transactionId) {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "finishPurchase", arguments, true);
		}
	};

	/**
	* Consumes a purchase. This makes that product to be purchasable again. 
	* @memberof Cocoon.Store
	* @function consume
	* @param {string} transactionId The transaction Id of the purchase to consume.
	* @param {string} productId The product Id of the product to be consumed.
	* @example
    * Cocoon.Store.on("consume",{
    * 	started: function(transactionId){ ... },
    * 	success: function(transactionId){ ... },
    * 	error: function(transactionId, err){ ... }
    * });
	* Cocoon.Store.consume("magic.sword");
	*/ 
	extension.consume = function(transactionId, productId) {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "consumePurchase", arguments, true);
		}
	};

	/**
	* Requests a product purchase given it's product id. 
	* @memberof Cocoon.Store
	* @function purchase
	* @param {string} productId The id or alias of the product to be purchased.
	* @example
    * Cocoon.Store.on("purchase",{
    * 	started: function(productId){ ... },
    * 	success: function(purchaseInfo){ ... },
    * 	verification: function(productId,data){ ... }, // This callback will be fired only when using "unmanaged" mode
    * 	error: function(productId, err){ ... }
    * });
	* Cocoon.Store.purchase("magic.sword");
	*/ 
	extension.purchase = function(productId) {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "purchaseFeature", arguments, true);
		}
	};

	/**
	* Requests a product purchase given it's product id showing a modal progress dialog. 
	* @memberof Cocoon.Store
	* @function puchaseProductModal
	* @param {string} productId The id or alias of the product to be purchased.
	* @private
	* @example
    * Cocoon.Store.on("purchase",{
    * 	started: function(productId){ ... },
    * 	success: function(purchaseInfo){ ... },
    * 	verification: function(productId,data){ ... }, // This callback will be fired only when using "unmanaged" mode
    * 	error: function(productId, err){ ... }
    * });
	* Cocoon.Store.puchaseProductModal("magic.sword");
	*/ 
	extension.puchaseProductModal = function(productId) {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "purchaseFeatureModal", arguments, true);
		}
	};

	/**
	* Requests a product purchase given it's product id showing a modal progress dialog. 
	* @memberof Cocoon.Store
	* @function purchaseProductModalWithPreview
	* @param {string} productId The id or alias of the product to be purchased.
	* @private
	* @example
    * Cocoon.Store.on("purchase",{
    * 	started: function(productId){ ... },
    * 	success: function(purchaseInfo){ ... },
    * 	verification: function(productId,data){ ... }, // This callback will be fired only when using "unmanaged" mode
    * 	error: function(productId, err){ ... }
    * });
	* Cocoon.Store.purchaseProductModalWithPreview("magic.sword");
	*/ 
	extension.purchaseProductModalWithPreview = function(productId) {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "purchaseFeatureModalWithPreview", arguments, true);
		}
	};

	/**
	* Returns if a product has been already purchased or not. 
	* @memberof Cocoon.Store
	* @function isProductPurchased
	* @param {string} productId The product id or alias of the product to be checked.
	* @returns {boolean} A boolean that indicates whether the product has been already purchased.
	*/
	extension.isProductPurchased = function(productId) {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "isFeaturePurchased", arguments);
		}
	};

	/**
	* Restores all the purchases from the platform's market. 
	* For each already purchased product the event "restore" will be called.
	* @memberof Cocoon.Store
	* @function restore
	* @example
    * Cocoon.Store.on("restore",{
    * 	started: function(){ ... },
    * 	success: function(){ ... },
    * 	error: function(errorMessage){ ... }
    * });
	* Cocoon.Store.restore();
	*/
	extension.restore = function() {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "restorePurchases", arguments, true);
		}
	};

	/**
	* @memberof Cocoon.Store
	* @private
	* @function restore
	* @example
    * Cocoon.Store.on("restore",{
    * 	started: function(){ ... },
    * 	success: function(){ ... },
    * 	error: function(errorMessage){ ... }
    * });
	* Cocoon.Store.restorePurchasesModal();
	*/
	extension.restorePurchasesModal = function() {
		if (Cocoon.Store.nativeAvailable)
		{
		return Cocoon.callNative("IDTK_SRV_STORE", "restorePurchasesModal", arguments, true);
		}
	};

	/**
	* Returns all the locally stored products.
	* @memberof Cocoon.Store
	* @function getProducts
	* @returns {Cocoon.Store.ProductInfo} An array with all the objects available for purchase.
	*/
	extension.getProducts = function() {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "getProducts", arguments);
		}
	};

	/**
	* Adds a product to the products local DB. 
	* @memberof Cocoon.Store
	* @function addProduct
	* @param {Cocoon.Store.ProductInfo} product The product to be added to the local products DB.
	*/
	extension.addProduct = function(product) {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "addProduct", arguments);
		}
	};

	/**
	* Removes a product from the products local DB given its productId. 
	* @memberof Cocoon.Store
	* @function removeProduct
	* @param {string} productId The product or alias of the product to be removed from the local products DB.
	*/
	extension.removeProduct = function(productId) {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "removeProduct", arguments);
		}
	};

	/**
	* Returns all the locally stored purchases.
	* @memberof Cocoon.Store
	* @function getPurchases
	* @returns {Cocoon.Store.PurchaseInfo} An array with all the completed purchases.
	*/
	extension.getPurchases = function() {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "getPurchases", arguments);
		}
	};

	/**
	* Adds a purchase to the local purchases DB. 
	* @memberof Cocoon.Store
	* @function addPurchase
	* @param {Cocoon.Store.PurchaseInfo} purchase The purchase to be added.
	*/
	extension.addPurchase = function(purchase) {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "addPurchase", arguments);
		}
	};

	/**
	* Removes a purchase from the local purchases DB given it's transaction id. 
	* @memberof Cocoon.Store
	* @function removePurchase
	* @param {string} transactionId The id of the transaction to be removed.
	*/ 
	extension.removePurchase = function(transactionId) {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "removePurchase", arguments);
		}
	};

	/**
	* (TESTING ONLY) Simulate a purchase cancel. 
	* This method is not allowed in production services and will only work in Mocks. 
	* @private
	* @memberof Cocoon.Store
	* @function cancelPurchase
	* @param {string} transactionId The transactionId of the purchase to be canceled.
	*/
	extension.cancelPurchase = function(transactionId) {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "cancelPurchase", arguments);
		}
	};

	/**
	* (TESTING ONLY) Simulates a purchase refundment. 
	* This method is not allowed in production services and will only work in Mocks.
	* @private
	* @memberof Cocoon.Store
	* @function refundPurchase
	* @param {string} transactionId The transactionId of the purchase to be refunded.
	*/
	extension.refundPurchase = function(transactionId) {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "refundPurchase", arguments);
		}
	};

	/**
	* (TESTING ONLY) Simulates a purchase expiration. 
	* This method is not allowed in production services and will only work in Mocks.
	* @private
	* @memberof Cocoon.Store
	* @function expirePurchase
	* @param {string} transactionId The transactionId of the purchase to be expired.
	*/
	extension.expirePurchase = function(transactionId) {
		if (Cocoon.Store.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_STORE", "expirePurchase", arguments);
		}
	};

	extension.onProductsFetchStarted = new Cocoon.EventHandler("IDTK_SRV_STORE", "Store", "onProductsFetchStarted");

	extension.onProductsFetchCompleted = new Cocoon.EventHandler("IDTK_SRV_STORE", "Store", "onProductsFetchCompleted"); 

	extension.onProductsFetchFailed = new Cocoon.EventHandler("IDTK_SRV_STORE", "Store", "onProductsFetchFailed"); 

	extension.onProductPurchaseStarted = new Cocoon.EventHandler("IDTK_SRV_STORE", "Store", "onProductPurchaseStarted"); 

	extension.onProductPurchaseVerificationRequestReceived = new Cocoon.EventHandler("IDTK_SRV_STORE", "Store", "onProductPurchaseVerificationRequestReceived");

	extension.onProductPurchaseCompleted = new Cocoon.EventHandler("IDTK_SRV_STORE", "Store", "onProductPurchaseCompleted"); 

	extension.onProductPurchaseFailed = new Cocoon.EventHandler("IDTK_SRV_STORE", "Store", "onProductPurchaseFailed"); 

	extension.onRestorePurchasesStarted = new Cocoon.EventHandler("IDTK_SRV_STORE", "Store", "onRestorePurchasesStarted"); 

	extension.onRestorePurchasesCompleted = new Cocoon.EventHandler("IDTK_SRV_STORE", "Store", "onRestorePurchasesCompleted"); 

	extension.onRestorePurchasesFailed = new Cocoon.EventHandler("IDTK_SRV_STORE", "Store", "onRestorePurchasesFailed");

	extension.onConsumePurchaseStarted = new Cocoon.EventHandler("IDTK_SRV_STORE", "Store", "onConsumePurchaseStarted"); 

	extension.onConsumePurchaseCompleted = new Cocoon.EventHandler("IDTK_SRV_STORE", "Store", "onConsumePurchaseCompleted"); 

	extension.onConsumePurchaseFailed = new Cocoon.EventHandler("IDTK_SRV_STORE", "Store", "onConsumePurchaseFailed");
	
	var signal = new Cocoon.Signal.createSignal();
	
	/**
     * Allows to listen to events about the loading process. 
     * - The callback 'started' receives no parameters when the products fetch has started.
     * - The callback 'success' receives a parameter with the valid products array when the products fetch has completed.
     * - The callback 'error' receives an error message as a parameter when the products fetch has failed.
     * @event On load products callbacks
     * @memberof Cocoon.Store
     * @example
     * Cocoon.Store.on("load",{
     * 	started: function(){ ... },
     * 	success: function(products){ ... },
     * 	error: function(errorMessage){ ... }
     * });
     */
	signal.register("load", {
		started : extension.onProductsFetchStarted,
		success : extension.onProductsFetchCompleted,
		error : extension.onProductsFetchFailed
	});

	/**
     * Allows to listen to events about the purchasing process.
     * - The callback 'started' receives a parameters with the product id of the product being purchased when the purchase of a product starts.
	 * - The callback 'success' receives as parameter the information of the purchase {@link Cocoon.Store.PurchaseInfo} when the purchase of a product succeeds.     
     * - The callback 'verification' receives two parameters, one with the productId of the purchased product and another one with a JSON object containing the data to be verified when a request for purchase verification has been received from the Store. 
     * In Android this JSON object will containt two keys: signedData and signature. You will need that information to verify the purchase against the backend server.
	 * - The callback 'error' receives a parameters with the product id and an error message when the purchase of a product fails.
     * @event On purchase products callbacks
     * @memberof Cocoon.Store
     * @example
     * Cocoon.Store.on("purchase",{
     * 	started: function(productId){ ... },
     * 	success: function(purchaseInfo){ ... },
     * 	verification: function(productId,data){ ... }, // This callback will be fired only when using "unmanaged" mode
     * 	error: function(productId, err){ ... }
     * });
     */
	signal.register("purchase", {
		started : extension.onProductPurchaseStarted,
		success : extension.onProductPurchaseCompleted,
		verification : extension.onProductPurchaseVerificationRequestReceived,
		error : extension.onProductPurchaseFailed
	});

	/**
     * Allows to listen to events about the consuming process.
     * - The callback 'started' receives a parameters with the transaction id of the purchase being consumed when the consume purchase operation has started.
     * - The callback 'success' receives a parameters with the transaction id of the consumed purchase when the consume purchase operation has completed.
     * - The callback 'error' receives a parameters with the transaction id  of the purchase that couldn't be consumed and the error message when the consume purchase operation has failed.
     * @event On consume products callbacks
     * @memberof Cocoon.Store
     * @example
     * Cocoon.Store.on("consume",{
     * 	started: function(transactionId){ ... },
     * 	success: function(transactionId){ ... },
     * 	error: function(transactionId, err){ ... }
     * });
     */
	signal.register("consume", {
		started : extension.onConsumePurchaseStarted,
		success : extension.onConsumePurchaseCompleted,
		error : extension.onConsumePurchaseFailed
	});

	/**
     * Allows to listen to events about the restoring process.
     * - The callback 'started' receives no parameters when the restore purchases operation has started.
     * - The callback 'success' receives no parameters when the restore purchases operation has completed.
     * - The callback 'error' receives an error message as a parameter when the restore purchases operation has failed.
     * @event On restore products callbacks
     * @memberof Cocoon.Store
     * @example
     * Cocoon.Store.on("restore",{
     * 	started: function(){ ... },
     * 	success: function(){ ... },
     * 	error: function(errorMessage){ ... }
     * });
     */
	signal.register("restore", {
		started : extension.onRestorePurchasesStarted,
		success : extension.onRestorePurchasesCompleted,
		error : extension.onRestorePurchasesFailed
	});

	extension.on = signal.expose();

	return extension;
});;/**
 * This namespace represents the Cocoon Notification extension.
 * The following image illustrates how the notification would look like when it arrives to your device. 
 *
 * <div> <img src="img/cocoon-notification.jpg"  height="35%" width="35%"/> <br/> <br/></div>
 * <p>You will find a complete example about how to use this extension in the Local namespace.<p> 
 *
 * <div class="alert alert-success">
 *   Here you will find a demo about this namespace: <a href="https://github.com/ludei/cocoonjs-demos/tree/master/Notifications">Notifications demo</a>.
 * </div>
 * 
 * @namespace Cocoon.Notification
 */
Cocoon.define("Cocoon.Notification" , function(extension){

    extension.nativeAvailable = (!!window.ext) && (!!window.ext.IDTK_SRV_NOTIFICATION);

    /**
	 * This namespace represents the Cocoon Notification extension for local notifications.
	 * @namespace Cocoon.Notification.Local
	 * @example 
	 * Cocoon.Notification.Local.on("notification", {
	 *   received: function(userData){
     * 	      console.log("A local notification has been received: " + JSON.stringify(userData));
     *   }
	 * });
	 *
	 * var notificationConfig = {
	 *	message : "Hi, I am a notification",
	 *	soundEnabled : true,
	 *	badgeNumber : 0,
	 *	userData : {"key1" : "value1", "key2": "value2"},
	 *	contentBody : "",
	 *	contentTitle : "",
	 *	date : new Date().valueOf() + 1000
	 * };
	 *	 
	 * var localNotification = Cocoon.Notification.Local.create(notificationConfig);
	 *
	 * Cocoon.Notification.Local.send(localNotification);
	 * Cocoon.Notification.start();
	 */
    extension.Local = {};
    /**
	 * This namespace represents the Cocoon Notification extension for push notifications.
	 * @namespace Cocoon.Notification.Push
	 */
    extension.Push = {};

    /**
	* Returns an object that represents the information of a local notification.
	* @memberOf Cocoon.Notification.Local
	* @function create
	* @example
	* var notificationConfig = {
	*	message : "Hi, I am a notification",
	*	soundEnabled : true,
	*	badgeNumber : 0,
	*	userData : {"key1" : "value1", "key2": "value2"},
	*	contentBody : "",
	*	contentTitle : "",
	*	date : new Date().valueOf() + 5000 // It will be fired in 5 seconds. 
	* };
	*	 
	* var localNotification = Cocoon.Notification.Local.create(notificationConfig);
    * @param {object} 	params - The object itself
	* @param {string} 	params.message The notification message. By default, it will be empty. 
	* @param {boolean} 	params.soundEnabled A flag that indicates if the sound should be enabled for the notification. By default, it will be true. 
	* @param {number} 	params.badgeNumber The number that will appear in the badge of the application icon in the home screen. By default, it will be 0. 
	* @param {object} 	params.userData The JSON data to attached to the notification. By default, it will be empty. 
	* @param {string} 	params.contentBody The body content to be showed in the expanded notification information. By default, it will be empty. 
	* @param {string} 	params.contentTitle The title to be showed in the expanded notification information. By default, it will be empty. 
	* @param {number} 	params.date Time in millisecs from 1970 when the notification will be fired. By default, it will be 1 second (1000).
    */
	extension.Local.create = function(params)
	{
		var properties = {
			message : "",
			soundEnabled : true,
			badgeNumber : 0,
			userData : {},
			contentBody : "",
			contentTitle : "",
			date : new Date().valueOf() + 1000
		};

		var args = Cocoon.clone(properties,params);

		if (Cocoon.Notification.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_NOTIFICATION", "createLocalNotification", args);
		}
	};

	/**
	* Returns an object structure that represents the information of a push notification.
	* @memberOf Cocoon.Notification.Push
	* @function create
	* @example 
	* var notificationConfig = {
	*	message : "Hi, I am a notification",
	*	soundEnabled : true, 
	*	badgeNumber : 0, 
	*	userData : {"key1" : "value1", "key2": "value2"},
	*	channels : "", 
	*	expirationTime : new Date().valueOf() +  3600, // The notification will be no longer valid in a hour. 
	*	expirationTimeInterval :  3600 // The notification will be no longer valid in a hour. 
	* };
	*	 
	* var pushNotification = Cocoon.Notification.Push.create(notificationConfig);
    * @param {object} 	params - The object itself
	* @param {string} 	params.message The notification message. By default, it will be empty. 
	* @param {boolean} 	params.soundEnabled A flag that indicates if the sound should be enabled for the notification. By default, it will be true. 
	* @param {number} 	params.badgeNumber The number that will appear in the badge of the application icon in the home screen.By default, it will be 0. 
	* @param {object} 	params.userData The JSON data to attached to the notification. By default, it will be empty. 
	* @param {array} 	params.channels An array containing the channels names this notification will be delivered to. By default, it will be empty. 
	* @param {number} 	params.expirationTime A time in seconds from 1970 when the notification is no longer valid and will not be delivered in case it has not already been delivered. By default, it will be 0.
	* @param {number} 	params.expirationTimeInterval An incremental ammount of time in from now when the notification is no longer valid and will not be delivered in case it has not already been delivered. By default, it will be 0.
    */
	extension.Push.create = function(params)
	{
		var properties = {
		message : "",
		soundEnabled : true,
		badgeNumber : 0,
		userData : {},
		channels : [],
		expirationTime : 0,
		expirationTimeInterval : 0
		};

		for (var prop in properties) {
			if (!params[prop]) {
				params[prop] = properties[prop];
			}
		}

		return params;
	};

	/**
	* Starts processing received notifications. The user must call this method when the game is ready to process notifications. Notifications received before being prepared are stored and processed later.
	* @memberOf Cocoon.Notification
	* @function start
    */
	extension.start = function()
	{
		if (Cocoon.Notification.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_NOTIFICATION", "start", arguments);
		}
	};

	/**
	* Registers to be able to receive push notifications.
	* @memberOf Cocoon.Notification.Push
	* @function register
    */
	extension.Push.register = function()
	{
		if (Cocoon.Notification.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_NOTIFICATION", "registerForPushNotifications", arguments, true);
		}
	};

	/**
	* Unregisters from receiving push notifications.
	* @memberOf Cocoon.Notification.Push
	* @function unregister
    */
	extension.Push.unregister = function()
	{
		if (Cocoon.Notification.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_NOTIFICATION", "unregisterForPushNotifications", arguments, true);
		}
	};

	/**
	* Cancels the local notification with Id provided.
	* The last sent local notification will be remove from the notifications bar.
	* @memberOf Cocoon.Notification.Local
	* @function cancel
    */
	extension.Local.cancel = function()
	{
		if (Cocoon.Notification.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_NOTIFICATION", "cancelLocalNotification", arguments);
		}
	};

	/**
	* Cancels the last sent local notification.
	* The last sent local notification will be remove from the notifications bar.
	* @memberOf Cocoon.Notification.Local
	* @function cancelLast
    */
	extension.Local.cancelLast = function()
	{
		if (Cocoon.Notification.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_NOTIFICATION", "cancelLocalNotification", arguments, true);
		}
	};

	/**
	* Cancels all sent local notifications.
	* All the notifications will ve removed from the notifications bar.
	* @memberOf Cocoon.Notification.Local
	* @function cancelAllNotifications
    */
	extension.Local.cancelAllNotifications = function()
	{
		if (Cocoon.Notification.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_NOTIFICATION", "cancelAllLocalNotifications", arguments);
		}
	};

	/**
	* Sends a local notification.
	* @memberOf Cocoon.Notification.Local
	* @function send
    */
	extension.Local.send = function(localNotification)
	{
		if (Cocoon.Notification.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_NOTIFICATION", "sendLocalNotification", arguments, true);
		}
	};

	/**
	* Subscribes to a channel in order to receive notifications targeted to that channel.
	* @memberOf Cocoon.Notification
	* @function subscribe
    */
	extension.subscribe = function(channel)
	{
		if (Cocoon.Notification.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_NOTIFICATION", "subscribe", arguments, true);
		}
	};

	/**
	* Unsubscribes from a channel in order to stop receiving notifications targeted to it.
	* @memberOf Cocoon.Notification
	* @function unsubscribe
    */
	extension.unsubscribe = function(channel)
	{
		if (Cocoon.Notification.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_NOTIFICATION", "unsubscribe", arguments, true);
		}
	};

	/**
	* Sends a push notification.
	* @memberOf Cocoon.Notification.Push
	* @function send
    */
	extension.Push.send = function(pushNotification)
	{
		if (Cocoon.Notification.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_NOTIFICATION", "sendPushNotification", arguments, true);
		}
	};

	/**
	* (iOS only) Sets the badge number for this application.
	* This is useful if you want to modify the badge number set by a notification.
	* @memberOf Cocoon.Notification
	* @function setBadgeNumber
    */
	extension.setBadgeNumber = function(badgeNumber)
	{
		if (Cocoon.Notification.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_NOTIFICATION", "setBadgeNumber", arguments);
		}
	};

	/**
	* (iOS only) Returns the current badge number.
	* @memberOf Cocoon.Notification
	* @function getBadgeNumber
    */
	extension.getBadgeNumber = function()
	{
		if (Cocoon.Notification.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_NOTIFICATION", "getBadgeNumber", arguments);
		}
	};

	/**
	* Returns the last received user data from a Local notification.
	* @memberOf Cocoon.Notification.Local
	* @function getLastNotificationData
    */
	extension.Local.getLastNotificationData = function()
	{
		if (Cocoon.Notification.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_NOTIFICATION", "getLastReceivedLocalNotificationData", arguments);
		}
	};

	/**
	* Returns the last received user data from a Push notification.
	* @memberOf Cocoon.Notification.Push
	* @function getLastNotificationData
    */
	extension.Push.getLastNotificationData = function()
	{
		if (Cocoon.Notification.nativeAvailable)
		{
			return Cocoon.callNative("IDTK_SRV_NOTIFICATION", "getLastReceivedPushNotificationData", arguments);
		}
	};

	extension.onRegisterForPushNotificationsSucceed = new Cocoon.EventHandler("IDTK_SRV_NOTIFICATION", "Notification", "pushNotificationServiceRegistered");

	extension.onUnregisterForPushNotificationsSucceed = new Cocoon.EventHandler("IDTK_SRV_NOTIFICATION", "Notification", "pushNotificationServiceUnregistered");

	extension.onRegisterForPushNotificationsFailed = new Cocoon.EventHandler("IDTK_SRV_NOTIFICATION", "Notification", "pushNotificationServiceFailedToRegister");

	extension.onPushNotificationReceived = new Cocoon.EventHandler("IDTK_SRV_NOTIFICATION", "Notification", "pushNotificationReceived");

	extension.onLocalNotificationReceived = new Cocoon.EventHandler("IDTK_SRV_NOTIFICATION", "Notification", "localNotificationReceived");

	extension.onPushNotificationDeliverySucceed = new Cocoon.EventHandler("IDTK_SRV_NOTIFICATION", "Notification", "pushNotificationSuccessfullyDelivered");

	extension.onPushNotificationDeliveryFailed = new Cocoon.EventHandler("IDTK_SRV_NOTIFICATION", "Notification", "pushNotificationDeliveryError");

	var signal = new Cocoon.Signal.createSignal();

	/**
	* Allows to listen  to events called when a local notification is received.
	* - The callback 'received' receives a parameter with the userData of the received notification when a local notification is received.
    * @event On received for local notifications callback  
    * @memberof Cocoon.Notification.Local
	* @example
	* Cocoon.Notification.Local.on("notification", {
    *	received : function(userData){
    * 	 	console.log("A local notification has been received: " + JSON.stringify(userData));
    *	}
	* });
    */
    signal.register("notification", {
    	received : extension.onLocalNotificationReceived
    });

	extension.Local.on = signal.expose();

	var signal = new Cocoon.Signal.createSignal();

	/**
	* Allows to listen to events called about the registration for push notification.
	* - The callback 'success' does not receive any parameter when the registration for push notification succeeds.
	* - The callback 'unregister' does not receive any parameter when the unregistration for push notifications succeeds.
	* - The callback 'error' receives a parameter with error information when the registration for push notifications fails.
    * @event On register for push notifications callbacks
    * @memberof Cocoon.Notification.Push
    * @example
	* Cocoon.Notification.Push.on("register", {
    * 	success : function(){ ... }
    *	unregister : function(){ ... }
    *	error : function(error){ ... }
	* });
    */
    signal.register("register", {
    	success : extension.onRegisterForPushNotificationsSucceed,
    	unregister : extension.onUnregisterForPushNotificationsSucceed,
    	error : extension.onRegisterForPushNotificationsFailed
    });

	/**
	* Allows to listen to events called when a push notification  is received.
	* - The callback 'received' receives a parameter with the userData of the received notification when a push notification is received.
    * @event On received for push notifications callback
    * @memberof Cocoon.Notification.Push
	* @example
	* Cocoon.Notification.Push.on("notification",{
	*	received : function(userData){
    * 		console.log("A push notification has been received: " + JSON.stringify(userData));
    *	}
	* });
    */
    signal.register("notification", {
    	received : extension.onPushNotificationReceived,
    });

	/**
	* Allows to listen to events called about the delivery proccess.
	* - The callback 'success' receives a parameter with the notificationId of the delivered notification when a notification is successfully delivered.
	* - The callback 'error' receives a parameter with error information when the delivery of a push notification fails.
    * @event On deliver for push notifications callbacks
    * @memberof Cocoon.Notification.Push
	* @example 
	* Cocoon.Notification.Push.on("deliver", {
    * 	success : function(notificationId){ ... }
    *	error : function(error){ ... }
	* });
    */
    signal.register("deliver", {
    	success : extension.onPushNotificationDeliverySucceed,
    	error : extension.onPushNotificationDeliveryFailed
    });

	extension.Push.on = signal.expose();

    return extension;

});;/**
 * This namespace provides an abstraction API for all the Social Services.
 * Each Social service has it's own official API but can also be used within this API interface.<br/>
 * Note that this javascript extension can be used to manage <b>Leaderboards and Achievements.</b> <br/>
 * In order to understand how to use the social javascript extension refer to the social service you would like to to use:
 * - <a href="Cocoon.Social.Facebook.html">Facebook</a>
 * - <a href="Cocoon.Social.GooglePlayGames.html">Google Play Games</a>
 * - <a href="Cocoon.Social.GameCenter.html">Game Center</a>
 * @namespace Cocoon.Social
 */
Cocoon.define("Cocoon.Social" , function(extension){

    /**
    * This interface provides an abstraction API for all the Social Services, this is an interface and never should be call directly. 
    * Each Social service has it's own official API but can also be used within this API interface. In order to use this 
    * interface you should call the method getSocialInterface(); that is available in the following classes:
    * - <a href="Cocoon.Social.Facebook.html">Facebook</a>
    * - <a href="Cocoon.Social.GooglePlayGames.html">Google Play Games</a>
    * - <a href="Cocoon.Social.GameCenter.html">Game Center</a>
    * @namespace Cocoon.Social.Interface
    * @example 
    * // You can use one of these 3 services with the same API.
    * // In this example we'll use Facebook
    * var service = Cocoon.Social.Facebook;
    * //var service = Cocoon.Social.GameCenter;
    * //var service = Cocoon.Social.GooglePlayGames;
    * 
    * // Each service has it's own init method,
    * // Refer to each service API to know how to initialize it.
    * service.init({
    *     appId: "XXXXXXXXXXXXXXXXXXXXX",
    *     channelUrl: "//connect.facebook.net/en_US/all.js"
    * });
    * 
    * var socialService = service.getSocialInterface();
    *  
    * function loginFacebook() {
    *   if (!socialService.isLoggedIn()) {
    *       socialService.login(function(loggedIn, error) {
    *           if (error) {
    *               console.error("login error: " + error.message);
    *           }
    *           else if (loggedIn) {
    *               var message = new Cocoon.Social.Message(
    *                   "Hello from the CocoonJS Launcher App! Are you a HTML5 game developer? Come and check out CocoonJS!",
    *                   "https://cocoonjsadmin.ludei.com/static/images/cocoon_logo.png",
    *                   "http://ludei.com",
    *                   "Ludei & CocoonJS",
    *                   "We love HTML5 games!");
    *
    *               socialService.publishMessageWithDialog(message, function(error) {
    *                   if (error) {
    *                       console.error("Error publishing message: " + error.message);
    *                   }
    *               });
    *            }
    *            else {
    *               console.log("login cancelled");
    *            }
    *       });
    *   }
    * }   
    * loginFacebook(); 
    */
    extension.Interface = function() {

        this.onLoginStatusChanged = new Cocoon.EventHandler("", "dummy", "onLoginStatusChanged");
        
        var signal = new Cocoon.Signal.createSignal();
        signal.register("loginStatusChanged", this.onLoginStatusChanged);
        this.on = signal.expose();

        return this;
    };

    extension.Interface.prototype = {
     
        /**
        * Checks if the user is logged in.
        * @return {boolean} true if the user is still logged in, false otherwise.
        * @function isLoggedIn
        * @memberOf Cocoon.Social.Interface
        */
        isLoggedIn: function() {
             return false;
        },

        /**
        * Authenticates the user.
        * @function login     
        * @memberOf Cocoon.Social.Interface
        * @param {function} callback The callback function. Response params: loggedIn(boolean) and error
        * @example
        * var fb = Cocoon.Social.Facebook;
        *
        * fb.init({
        *     appId: "XXXXXXXXXXXXXXXXXXXXX",
        *     channelUrl: "//connect.facebook.net/en_US/all.js"
        * });
        * 
        * var socialService = fb.getSocialInterface();
        * var loggedIn = socialService.isLoggedIn();
        *
        * function loginFacebook() {
        *   if (!socialService.isLoggedIn()) {
        *       socialService.login(function(loggedIn, error) {
        *            if (error) {
        *               console.error("login error: " + error.message);
        *            }
        *            else if (loggedIn) {
        *               console.log("login succeeded");
        *            }
        *            else {
        *               console.log("login cancelled");
        *            }
        *       });
        *   }
        * }
        * loginFacebook();
        */
        login : function(callback) {
            if (callback)
                callback(false, {message:"Not implemented!"});
        },

        /**
        * Logs the user out of your application.
        * @function logout     
        * @memberOf Cocoon.Social.Interface        
        * @param {function} [callback] The callback function. Response params: error.
        * @example
        * var fb = Cocoon.Social.Facebook;
        *
        * fb.init({
        *     appId: "XXXXXXXXXXXXXXXXXXXXX",
        *     channelUrl: "//connect.facebook.net/en_US/all.js"
        * });
        * 
        * var socialService = fb.getSocialInterface();
        *
        * socialService.logout(function(error){
        *
        * });
        */
        logout: function(callback) {
            if (callback)
                callback({message:"Not implemented!"});
        },

        /**
        * Returns the information of the currently logged in user.
        * @function getLoggedInUser     
        * @memberOf Cocoon.Social.Interface             
        * @return {@link Cocoon.Social.User}
        */
        getLoggedInUser : function() {
            return null;
        },

        /**
        * Checks if the current logged in user has publish permissions.
        * @function hasPublishPermissions     
        * @memberOf Cocoon.Social.Interface          
        * @param callback The callback function. It receives the following parameters: permissions granted and error
        */
        hasPublishPermissions: function(callback) {
            callback(true);
        },

        /**
        * Requests publish permissions for the current logged in user.
        * @function requestPublishPermissions     
        * @memberOf Cocoon.Social.Interface            
        * @param callback The callback function. It receives the following parameters: granted and error
        */
        requestPublishPermissions: function(callback) {
            if (callback)
                callback(true, null);
        },

        /**
        * Retrieves user information for a specific user ID.
        * @function requestUser     
        * @memberOf Cocoon.Social.Interface       
        * @param {function} callback - The callback function. It receives the following parameters: 
        * - {@link Cocoon.Social.User}.
        * - Error.
        * @param {string} userID - The id of the user to retrieve the information from. If no userID is specified, the currently logged in user is assumed.
        * @example
        * var fb = Cocoon.Social.Facebook;
        *
        * fb.init({
        *     appId: "XXXXXXXXXXXXXXXXXXXXX",
        *     channelUrl: "//connect.facebook.net/en_US/all.js"
        * });
        * 
        * var socialService = fb.getSocialInterface();
        * var loggedIn = socialService.isLoggedIn();
        * 
        * if (loggedIn) {
        *   socialService.requestUser(function(user, error) {
        *        if (error) {
        *            console.error("requestUser error: " + error.message);
        *       }
        *       else {
        *           console.log(user.userName);
        *        }
        *   }, userID);
        * }
        */
        requestUser: function(callback, userID) {
            callback(null, {message:"Not implemented!"});
        },
        
        /**
        * Requests to retrieve the profile image of a user.
        * @function requestUserImage     
        * @memberOf Cocoon.Social.Interface         
        * @param {function} callback The callback function. It receives the following parameters: 
        * - ImageURL. 
        * - Error.
        * @param {string} userID The id of the user to get the image for. If no userID is specified, the currently logged user is used.
        * @param {Cocoon.Social.ImageSize} imageSize The desired size of the image. Default value: SMALL.
        */        
        requestUserImage: function(callback, userID, imageSize) {
            callback("", {message:"Not implemented!"})
        },

        /**
        * Retrieves user friends for a specific user ID.
        * @function requestFriends     
        * @memberOf Cocoon.Social.Interface          
        * @param {function} callback - The callback function. It receives the following parameters: 
        * - Array of {@link Cocoon.Social.User}. 
        * - Error.
        * @param {string} userID - The id of the user to retrieve the information from. If no userID is specified, the currently logged in user is assumed.
        * @example
        * var fb = Cocoon.Social.Facebook;
        *
        * fb.init({
        *     appId: "XXXXXXXXXXXXXXXXXXXXX",
        *     channelUrl: "//connect.facebook.net/en_US/all.js"
        * });
        * 
        * var socialService = fb.getSocialInterface();
        *
        * var loggedIn = socialService.isLoggedIn();
        * 
        * if (loggedIn) {
        *   socialService.requestFriends(function(friends, error) {
        *        if (error) {
        *            console.error("requestFriends error: " + error.message);
        *       }
        *       else {
        *          console.log("You have " + friends.length + " friends.");
        *        }
        *   });
        * }
        */
        requestFriends: function(callback, userID) {
            callback([], {message:"Not implemented!"});
        },

        /**
        * Shares a message without the intervention of the user.
        * This action might require publish permissions. If the user has not publish permissions they are automatically requested.
        * @function publishMessage   
        * @memberOf Cocoon.Social.Interface            
        * @param {Cocoon.Social.Message} message A object representing the information to be published.
        * @param {function} [callback] The callback function. It receives the following parameters: error.
        * @example
        * var fb = Cocoon.Social.Facebook;
        *
        * fb.init({
        *     appId: "XXXXXXXXXXXXXXXXXXXXX",
        *     channelUrl: "//connect.facebook.net/en_US/all.js"
        * });
        * 
        * var socialService = fb.getSocialInterface();
        * var loggedIn = socialService.isLoggedIn();
        * 
        * if (loggedIn) {
        *     var message = new Cocoon.Social.Message(
        *     "Hello from the CocoonJS Launcher App! Are you a HTML5 game developer? Come and check out CocoonJS!",
        *     "https://cocoonjsadmin.ludei.com/static/images/cocoon_logo.png",
        *     "http://ludei.com",
        *     "Ludei & CocoonJS",
        *     "We love HTML5 games!");
        *
        *     socialService.publishMessage(message, function(error) {
        *          if (error) {
        *              console.error("Error publishing message: " + error.message);
        *          }
        *      });
        * }
        */
        publishMessage: function(message, callback) {
            callback({message:"Not implemented!"});
        },

        /**
        * Presents a native/web dialog that allows the user to share a message.
        * @function publishMessageWithDialog   
        * @memberOf Cocoon.Social.Interface         
        * @param {Cocoon.Social.Message} message A object representing the information to be published
        * @param {function} callback The callback function. It receives the following parameters: error
        * @example 
        * var fb = Cocoon.Social.Facebook;
        *
        * fb.init({
        *     appId: "XXXXXXXXXXXXXXXXXXXXX",
        *     channelUrl: "//connect.facebook.net/en_US/all.js"
        * });
        * 
        * var socialService = fb.getSocialInterface();
        * var loggedIn = socialService.isLoggedIn();
        * 
        * if (loggedIn) {
        *     var message = new Cocoon.Social.Message(
        *     "Hello from the CocoonJS Launcher App! Are you a HTML5 game developer? Come and check out CocoonJS!",
        *     "https://cocoonjsadmin.ludei.com/static/images/cocoon_logo.png",
        *     "http://ludei.com",
        *     "Ludei & CocoonJS",
        *     "We love HTML5 games!");
        *
        *     socialService.publishMessageWithDialog(message, function(error) {
        *          if (error) {
        *              console.error("Error publishing message: " + error.message);
        *          }
        *      });
        * }   
        */        
        publishMessageWithDialog: function(message, callback) {
            callback({message:"Not implemented!"});
        }
    }


    extension.SocialGamingService = function() {
        Cocoon.Social.SocialGamingService.superclass.constructor.call(this);
        return this;
    }

    extension.SocialGamingService.prototype = {

        _cachedAchievements: null,
        _achievementsMap: null,
        _leaderboardsTemplate: null,
        _achievementsTemplate: null,
      
        /**
        * Retrieves the score for a user from a specific leaderboard
        * @function requestScore   
        * @memberOf Cocoon.Social.Interface 
        * @param {function} callback The callback function. It receives the following parameters: 
        * - {@link Cocoon.Social.Score}. 
        * - Error. 
        * @param {Cocoon.Social.ScoreParams} [params] The params to retrieve the score. If no params are specified, the currently logged in user and the default leaderboard are assumed.
        */      
        requestScore: function(callback, params) {
            callback(null, {message:"Not implemented!"})
        },

        /**
         * Submits the score for a user to a specific leaderboard
         * @function submitScore   
         * @memberOf Cocoon.Social.Interface 
         * @param {number} score The score to submit
         * @param {function} [callback] The callback function. Response params: error.
         * @param {Cocoon.Social.ScoreParams} [params] The params to submit the score. If no params are specified, the currently logged in user and the default leaderboard are assumed.
         */
        submitScore: function(score, callback, params ) {
            if (callback)
                callback({message:"Not implemented!"})
        },
        
        /**
        * Shows a modal leaderboard view using a platform dependant view.
        * @param {Cocoon.Social.ScoreParams} [params] The params to choose the leaderboard and other settings. If no params are specified the default leaderboard id and settings will be assumed.
        * @param {function} [callback] The callback function invoked when the modal leaderboard view is closed by the user. Response params: error.
        * @function showLeaderboard   
        * @memberOf Cocoon.Social.Interface     
        * @example 
        * var fb = Cocoon.Social.Facebook;
        *
        * fb.init({
        *     appId: "XXXXXXXXXXXXXXXXXXXXX",
        *     channelUrl: "//connect.facebook.net/en_US/all.js"
        * });
        * 
        * var socialService = fb.getSocialInterface();
        * var loggedIn = socialService.isLoggedIn();
        *
        * socialService.showLeaderboard(function(error){
        *     if (error)
        *         console.error("showLeaderbord error: " + error.message);
        * });
        */
        showLeaderboard : function(callback, params) {
            if (callback)
                callback({message:"Not implemented!"})
        },

        /**
        * Retrieves all the achievements of the application.
        * @function requestAllAchievements  
        * @memberOf Cocoon.Social.Interface 
        * @param {function} callback The callback function. It receives the following parameters: 
        * - Array of {@link Cocoon.Social.Achievement} 
        * - Error.
        */
        requestAllAchievements : function(callback) {
            callback([], {message:"Not implemented!"})
        },

        /**
         * Retrieves the achievements earned by a user.
         * @function requestAchievements  
         * @memberOf Cocoon.Social.Interface 
         * @param {function} callback The callback function. It receives the following parameters: 
         * - Array of {@link Cocoon.Social.Achievement}.
         * - Error.
         * @param {string} [userId] The id of the user to retrieve the information from. If no userID is specified, the currently logged in user is assumed.
         */
        requestAchievements : function(callback, userID) {
            callback([], {message:"Not implemented!"})
        },

        /**
        * Submits the achievement for the current logged In user
        * @function submitAchievements  
        * @memberOf Cocoon.Social.Interface 
        * @param achievementID The achievement ID to submit
        * @param callback [callback] The callback function. Response params: error.
        * @example
        * var fb = Cocoon.Social.Facebook;
        *
        * fb.init({
        *     appId: "XXXXXXXXXXXXXXXXXXXXX",
        *     channelUrl: "//connect.facebook.net/en_US/all.js"
        * });
        * 
        * var socialService = fb.getSocialInterface();
        *
        * socialService.submitAchievement( achievementID, function(error){
        *     if (error)
        *         console.error("submitAchievement error: " + error.message);
        * });
        */       
        submitAchievement: function(achievementID, callback) {
            if (callback)
                callback({message:"Not implemented!"})
        },
        
        /**
        * Resets all the achievements of the current logged in user
        * @function resetAchievements  
        * @memberOf Cocoon.Social.Interface          
        * @param {function} [callback] The callback function. Response params: error.
        * @example
        * var fb = Cocoon.Social.Facebook;
        *
        * fb.init({
        *     appId: "XXXXXXXXXXXXXXXXXXXXX",
        *     channelUrl: "//connect.facebook.net/en_US/all.js"
        * });
        * 
        * var socialService = fb.getSocialInterface();
        *
        * socialService.resetAchievements(function(error){
        *     if (error)
        *         console.error("resetAchievements error: " + error.message);
        * });
        */         
        resetAchievements : function(callback) {
            if (callback)
                callback([], {message:"Not implemented!"})
        },
     
       /**
        * Shows a modal achievements view using a platform dependant view.
        * @param {function} [callback] The callback function invoked when the modal achievements view is closed by the user. Response params: error.
        * @function showAchievements  
        * @memberOf Cocoon.Social.Interface     
        * @example 
        * var fb = Cocoon.Social.Facebook;
        *
        * fb.init({
        *     appId: "XXXXXXXXXXXXXXXXXXXXX",
        *     channelUrl: "//connect.facebook.net/en_US/all.js"
        * });
        * 
        * var socialService = fb.getSocialInterface();
        * var loggedIn = socialService.isLoggedIn();
        *
        * socialService.showAchievements(function(error){
        *     if (error)
        *         console.error("showAchievements error: " + error.message);
        * });
        */       
        showAchievements : function(callback) {
            if (!this._achievementsTemplate)
                throw "Please, provide a html template for achievements with the setTemplates method";
            var dialog = new Cocoon.Widget.WebDialog();
            var callbackSent = false;
            dialog.show(this._achievementsTemplate, function(error) {
                dialog.closed = true;
                if (!callbackSent && callback)
                    callback(error);
            });
            var me = this;
            this.requestAchievements(function(achievements, error){
                if (dialog.closed)
                    return;
                if (error) {
                    callbackSent = true;
                    if (callback)
                        callback(error);
                    return;
                }

                var achs = [];
                if (me._cachedAchievements) {
                    for (var i = 0; i < me._cachedAchievements.length; ++i) {
                        var ach = me._cachedAchievements[i];
                        achs.push(ach);
                        if (achievements && achievements.length) {
                            for (var j = 0; j< achievements.length; ++j) {
                                if (achievements[j].achievementID === ach.achievementID) {
                                    ach.achieved = true;
                                    break;
                                }
                            }
                        }
                    }
                }
                var js = "addAchievements(" + JSON.stringify(achs) + ");";
                dialog.eval(js);
            });
        },

        /**
         * Set the map for using custom achievement IDs.
         * The map must be a customID to realID map (accessing map.customID must return the real achievement ID).
         * Whenever this map is enabled users are able to submit achievements with the real achievement ID or with the custom one.
         * @params {object} map The achievements map. A null map disables this feature.
         * @function setAchievementsMap 
         * @memberOf Cocoon.Social.Interface 
         */
        setAchievementsMap: function(map) {
            this._achievementsMap = map;
            if (this._cachedAchievements) {
               this.syncAchievementsMap(this._cachedAchievements);
            }
        },
        /**
         * Provides some templates to be used in the leaderboards and achievements views
         * Some social services (like Facebook) don't have a native view to show achievements or leaderboards views, and use html templates instead.
         * @param {string} leaderboardsTemplate Relative path to the leaderboards template.
         * @param {string} achievementsTemplate Relative path to the achievements template.
         * @function setTemplates
         * @memberOf Cocoon.Social.Interface 
         */
        setTemplates: function(leaderboardsTemplate, achievementsTemplate) {
            this._leaderboardsTemplate = leaderboardsTemplate;
            this._achievementsTemplate = achievementsTemplate;
        },

        //Internal utility methods

        setCachedAchievements: function(achievements) {
            this._cachedAchievements = achievements;
            if (achievements && this._achievementsMap) {
                this.syncAchievementsMap(this._cachedAchievements);
            }
        },

        findAchievement: function(id) {
            if (!this._cachedAchievements)
                return null;
            for (var i = 0; i < this._cachedAchievements.length; ++i) {
                if (id === this._cachedAchievements[i].achievementID) {
                    return this._cachedAchievements[i];
                }
            }
            return null;
        },

        translateAchievementID: function(id) {
            if (this._achievementsMap) {
                for (var customID in this._achievementsMap) {
                    if (customID == id) { //important: compare with double equal, because id can be numeric
                        return this._achievementsMap[customID];
                    }
                }
            }
            return id;
        },
        
        syncAchievementsMap: function(achievements) {
            if (!this._achievementsMap)
                return;
            for (var i = 0; i< achievements.length; ++i) {
                for (var customID in this._achievementsMap) {
                     if (this._achievementsMap[customID] === achievements[i].achievementID) {
                         achievements[i].customID = customID;
                     }
                }
            }
        }
    }

    
    Cocoon.extend(extension.SocialGamingService, extension.Interface);

    /**
    * This object represents the possible images that can be obtained for a user in the social gaming extension.
    * @memberof Cocoon.Social  
    * @name Cocoon.Social.ImageSize
    * @property {object} Cocoon.Social.ImageSize - The object itself
    * @property {string} Cocoon.Social.ImageSize.THUMB Represent a thumbnail like image size.
    * @property {string} Cocoon.Social.ImageSize.SMALL Represents the small image size.
    * @property {string} Cocoon.Social.ImageSize.MEDIUM Represents the medium image size.
    * @property {string} Cocoon.Social.ImageSize.LARGE Represents the large image size.
    */   
    extension.ImageSize =
    {
    
        THUMB : "thumb",
    
        SMALL : "small",
    
        MEDIUM : "medium",
    
        LARGE : "large"
    };

    /**
    * The object that represents the information of a user inside the social gaming extension.
    * @memberof Cocoon.Social  
    * @name Cocoon.Social.User
    * @property {object} Cocoon.Social.User - The object itself
    * @property {string} Cocoon.Social.User.userID The id of the user.
    * @property {string} Cocoon.Social.User.userName The user name of the user.
    * @property {string} Cocoon.Social.User.userImage If the image URL is not provided by default, fetch it using requestUserImage method.
    */  
    extension.User = function(userID, userName, userImage)
    {
        
        this.userID = userID;
        
        this.userName = userName;

        this.userImage = userImage;

        return this;
    };

    /**
    * This object represents a message to be published.
    * @memberof Cocoon.Social  
    * @name Cocoon.Social.Message
    * @property {object} Cocoon.Social.Message - The object itself
    * @property {string} Cocoon.Social.Message.message  The message to be published.
    * @property {string} Cocoon.Social.Message.mediaURL An URL to a media (image, video, ...). 
    * @property {string} Cocoon.Social.Message.linkURL An URL to add to the message so the user can click on that link to get more information.
    * @property {string} Cocoon.Social.Message.linkText The text that will appear in the message link.
    * @property {string} Cocoon.Social.Message.linkCaption The text caption that will appear in the message link.
    */  
    extension.Message = function(message, mediaURL, linkURL, linkText, linkCaption)
    {
        
        this.message = message;
        
        this.mediaURL = mediaURL;
        
        this.linkURL = linkURL;
        
        this.linkText = linkText;
        
        this.linkCaption = linkCaption;

        return this;
    };

    /**
    * This object that represents the information of the user score in the application.
    * @memberof Cocoon.Social  
    * @name Cocoon.Social.Score
    * @property {object} Cocoon.Social.Score - The object itself
    * @property {string} Cocoon.Social.Score.userID The user id.
    * @property {number} Cocoon.Social.Score.score The score of the user.
    * @property {string} Cocoon.Social.Score.userName The name of the user.
    * @property {string} Cocoon.Social.Score.imageURL imageURL The url of the user image.
    * @property {number} Cocoon.Social.Score.leaderboardID The id of the leaderboard the score belongs to.
    */  
    extension.Score = function(userID, score, userName, imageURL, leaderboardID)
    {
        
        this.userID = userID;
        
        this.score = score || 0;
        
        this.userName = userName;
        
        this.imageURL = imageURL;
        
        this.leaderboardID = leaderboardID;

        return this;
    };

    /**
    * The object that represents params to retrieve or submit scores.
    * @memberof Cocoon.Social  
    * @name Cocoon.Social.ScoreParams
    * @property {object} Cocoon.Social.ScoreParams - The object itself
    * @property {string} Cocoon.Social.ScoreParams.userID The user id. If no userID is specified the current logged in user is assumed.
    * @property {number} Cocoon.Social.ScoreParams.leaderboardID The leaderboard ID. If no leaderboard is specified the default leaderboard is assumed.
    * @property {boolean} Cocoon.Social.ScoreParams.friends If enabled the query will get only scores from friends in the social network.
    * @property {Cocoon.Social.TimeScope} Cocoon.Social.ScoreParams.timeScope  The time scope for the scores.
    */ 
    extension.ScoreParams = function(userID, leaderboardID, friends, timeScope) {

        this.userID = userID;

        this.leaderboardID = leaderboardID;

        this.friends = !!friends;

        this.timeScope = timeScope || 2;
    }

    /**
    * This object represents the possible Time Scopes for a leaderboard query.
    * @memberof Cocoon.Social  
    * @name Cocoon.Social.TimeScope
    * @property {object} Cocoon.Social.TimeScope - The object itself
    * @property {string} Cocoon.Social.TimeScope.ALL_TIME All registered time.
    * @property {string} Cocoon.Social.TimeScope.WEEK A week.
    * @property {string} Cocoon.Social.TimeScope.TODAY Today.
    */ 
    extension.TimeScope =
    {
        ALL_TIME: 0,
        WEEK: 1,
        TODAY:2
    };

    /**
    * This object represents the possible Time Scopes for a leaderboard query.
    * @memberof Cocoon.Social  
    * @name Cocoon.Social.Achievement
    * @property {object} Cocoon.Social.Achievement - The object itself
    * @property {string} Cocoon.Social.Achievement.achievementID The id of the achievement info.
    * @property {string} Cocoon.Social.Achievement.customID The optional custom id of the achievement defined by the user.
    * @property {string} Cocoon.Social.Achievement.title The title of the achievement.
    * @property {string} Cocoon.Social.Achievement.description The description of the achievement.
    * @property {string} Cocoon.Social.Achievement.imageURL The url to the image representing the achievement.
    * @property {number} Cocoon.Social.Achievement.points The points value of the achievement.
    */ 
    extension.Achievement = function(achievementID, title, description, imageURL, points)
    {

        this.achievementID = achievementID;

        this.customID = achievementID;

        this.title = title;

        this.description = description;

        this.imageURL = imageURL;

        this.points = points || 0;

        return this;
    };

    /**
    * Opens a given share native window to share some specific text content in 
    * any system specific social sharing options. For example, Twitter, Facebook, SMS, Mail, ...
    * @memberOf Cocoon.Social
    * @function Share
    * @param textToShare {string} textToShare The text content that will be shared.
    * @example
    * Cocoon.Social.share("I have scored more points on Flappy Submarine!! Chooo choooo");
    */
    extension.share = function(textToShare) {
        if (Cocoon.nativeAvailable){
            return Cocoon.callNative("IDTK_APP", "share", arguments, true);
        }
        else {
            // TODO: Is there something we could do to share in a browser?
        }
    };

    return extension;
});;/**
 * 
 * @private
 * @namespace Cocoon.Social.Manager
 */
Cocoon.define("Cocoon.Social" , function(extension){

    extension.ManagerService = function() {
       this.services = [];
    }

    extension.ManagerService.prototype = {

        services:null,

        registerSocialService : function(service) {
            this.services.push(service);
        },

        submitAchievement : function(achievementID) {
            for (var i = 0; i < this.services.length; ++i) {
                var service = this.services[i];
                if (!service.readOnlyHint && service.isLoggedIn())  {
                    service.submitAchievement(achievementID, function(error) {
                        if (error)
                            console.error("Error submitting achievement: " + error.message);
                    });
                }
            }
        },

        submitScore : function(score, params) {
            for (var i = 0; i < this.services.length; ++i) {
                var service = this.services[i];
                if (!service.readOnlyHint && service.isLoggedIn())  {
                    service.submitScore(score, function(error) {
                        if (error)
                            console.error("Error submitting score: " + error.message);
                    }, params);
                }
            }
        },

        getLoggedInServices : function() {
            var result= [];

            for (var i = 0; i < this.services.length; ++i) {
                var service = this.services[i];
                if (!service.fakeSocialService &&  service.isLoggedIn())  {
                    result.push(service);
                }
            }
            return result;
        },

        isLoggedInAnySocialService : function() {
            return this.getLoggedInServices().length > 0;
        }
    }

    extension.Manager = new extension.ManagerService();
    
    return extension;
});;/**
 * This namespace represents all the basic functionalities available in the CocoonJS extension API.
 * @private
 * @namespace Cocoon.Social.LocalStorage
 */
Cocoon.define("Cocoon.Social" , function(extension){

    extension.LocalStorageService = function() {
        Cocoon.Social.LocalStorageService.superclass.constructor.call(this);
        this.fakeSocialService = true;
    }

    extension.LocalStorageService.prototype = {

        loggedIn: false,
        keys: {
            score: "Cocoon.Social.LocalStorageService.score",
            earnedAchievements: "Cocoon.Social.LocalStorageService.earned"
        },
        isLoggedIn: function() {
            return this.loggedIn;
        },

        login : function(callback) {
            if (!this.loggedIn)
                this.onLoginStatusChanged.notifyEventListeners(true);
            this.loggedIn = true;
            if (callback)
                setTimeout(function(){callback(true)},0);
        },

        logout: function(callback) {
            if (this.loggedIn)
                this.onLoginStatusChanged.notifyEventListeners(true);
            this.loggedIn = false;

            if (callback)
                setTimeout(function(){callback()},0);
        },

        getLoggedInUser : function() {
            return new Cocoon.Social.User("me", "LocalStorage");
        },

        requestUser: function(callback, userID) {
            var user = new Cocoon.Social.User(userID || "me", "LocalStorage");
            if (callback)
                setTimeout(function(){callback(user)},0);
        },

        requestScore: function(callback, params) {
            var scoreItem = localStorage.getItem(this.keys.score);
            var score = parseInt(scoreItem) || 0;
            setTimeout(function(){callback(new Cocoon.Social.Score("me", score))},0);
        },

        submitScore: function(score, callback, params ) {
            var scoreItem = localStorage.getItem(this.keys.score);
            var topScore = parseInt(scoreItem) || 0;
            if (score > topScore)
                localStorage.setItem(this.keys.score, score);
            if (callback)
                setTimeout(function(){callback()},0);
        },
        getLocalStorageEarnedAchievements: function() {
            var achievementsItem = localStorage.getItem(this.keys.earnedAchievements);
            var earned = [];
            if (achievementsItem) {
                var array = JSON.stringify(achievementsItem);
                if (array && array.length) {
                    earned = array;
                }
            }
            return earned;
        },
        requestAchievements : function(callback, userID) {
            var earned = this.getLocalStorageEarnedAchievements();
            setTimeout(function(){callback(earned)},0);
        },

        submitAchievement: function(achievementID, callback) {
            if (achievementID === null || typeof achievementID === 'undefined')
                throw "No achievementID specified";
            var earned = this.getLocalStorageEarnedAchievements();
            var exists = false;
            for (var i = 0; i< earned.length; ++i) {
               if (earned[i] === achievementID) {
                   exists = true;
                   break;
               }
            }
            if (!exists) {
                earned.push(achievementID);
                localStorage.setItem(this.keys.earnedAchievements, JSON.stringify(earned));
            }

            if (callback)
                setTimeout(function(){callback()},0);
        },
        resetAchievements : function(callback) {
            localStorage.removeItem(this.keys.earnedAchievements);
            if (callback)
                setTimeout(function(){callback()},0);
        }
    };

    Cocoon.extend(extension.LocalStorageService, extension.SocialGamingService);

    extension.LocalStorage = new extension.LocalStorageService();

    return extension;
});;/**
 * This namespace represents all the basic functionalities available in the CocoonJS extension API.
 *
 * <div class="alert alert-success">
 *   Here you will find a demo about this namespace: <a href="https://github.com/ludei/cocoonjs-demos/tree/Google%20Play%20Games">Google Play Games demo</a>.
 *</div>
 *
 * <div class="alert alert-warning">
 *    <strong>Warning!</strong> This JavaScript extension requires some configuration parameters on the <a href="https://ludei.zendesk.com/hc/en-us">cloud compiler</a>!
 * </div>
 * The following example shows the full process of how to publish a message using GooglePlay extension.The following image illustrates how the result should look like.  
 * <div><br/><img src="img/cocoon-socialgp-publish3.png" heigh="50%" width="55%"/> </div>
 * @namespace Cocoon.Social.GooglePlayGames
 * @example
 * var gp =  Cocoon.Social.GooglePlayGames;
 *
 * var iosClientId = "Your iOS Client ID"; //clientId is not required in android
 * var webClientId = "Your Web Client ID";
 *
 * gp.init({
 *     clientId: webClientId,
 *     defaultLeaderboard:"Your leaderboard ID"
 * });
 *
 * var socialService = gp.getSocialInterface();
 *     
 * function loginGP() {
 *  if (!socialService.isLoggedIn()) {
 *      socialService.login(function(loggedIn, error) {
 *          if (error) {
 *              console.error("login error: " + error.message);
 *          }
 *          else if (loggedIn) {
 *              var message = new Cocoon.Social.Message(
 *                  "Hello from the CocoonJS Launcher App! Are you a HTML5 game developer? Come and check out CocoonJS!",
 *                  "Ludei - We love HTML5 games!");
 *   
 *              socialService.publishMessageWithDialog(message, function(error) {
 *                  if (error) {
 *                      console.error("Error publishing message: " + error.message);
 *                  }
 *              });
 *          }
 *          else {
 *              console.log("login cancelled");
 *          }
 *      });
 *  }
 * }
 *
 * loginGP();  
 *
 */
Cocoon.define("Cocoon.Social" , function(extension){

    extension.GooglePlayGamesExtension = function (){
        this.nativeExtensionName = "IDTK_SRV_GOOGLE_PLAY_GAMES";
        this.extensionName = "Social.GooglePlayGames";
        this.nativeAvailable =  Cocoon.nativeAvailable && typeof window.ext[this.nativeExtensionName] !== 'undefined';

        this.auth = new Cocoon.Social.GooglePlayGamesAuthExtension(this);
        this.client = new Cocoon.Social.GooglePlayGamesClientExtension(this);
        this.defaultScopes = ["https://www.googleapis.com/auth/games","https://www.googleapis.com/auth/plus.login"];
        this.gamesAPI = "/games/v1";
        this.plusAPI = "/plus/v1";

        this.onSessionChanged = new Cocoon.EventHandler(this.nativeExtensionName, this.extensionName, "onSessionChanged");

        Cocoon.Social.GooglePlayGames = this; //the object it's being created but the addEventListener needs it now
        var me = this;
        this.onSessionChanged.addEventListener(function(session, error) {
            me.token = fromSessionToAuthTokenObject(session,error);
            if (session && session.access_token) {
                //fetch user data
                me.client.request({path: me.gamesAPI + "/players/me", callback: function(response) {
                    me.currentPlayer = response;
                }});
            }
        });

        return this;
    };

    extension.GooglePlayGamesExtension.prototype = {

        token: null,
        settings: {},
        socialService: null,
        currentPlayer: null,
        initialized: false,

        auth: null,
        client: null,

        /**
         * Initializes the service and tries to restore the last session.
         * @memberof Cocoon.Social.GooglePlayGames
         * @function init
         * @param {Object} params Initialization options.
         * @param {string} params.clientId The application clientID. Omit if its already provided in the native application via cloud configuration.
         * @param {string} params.defaultLeaderboard The default leaderboard ID. You can omit it if you specify the leaderboardID in all the score queries or submits.
         * @param {boolean} params.showAchievementNotifications Enables or disables the native view notifications when an achievement is unlocked.
         */
        init: function(params) {
            if (!params || typeof params !== 'object')
                throw "Invalid params argument";
            this.settings = params;
            this.initialized = true;
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "init", [this.settings.clientId], true);
            }
            else {

                var me = this;
                var initWebAPi = function() {
                    gapi.auth.authorize({immediate: true, scope: me.defaultScopes, client_id:me.settings.clientId},function(response) {
                        me.token = response;
                        if (response && response.access_token) {
                            me.onSessionChanged.notifyEventListeners(response);
                        }
                    })
                }

                if (!window.gapi) {
                    window.onGapiLoadCallback = function() {
                        //initialization timeout recommended by google to avoid some race conditions
                        window.setTimeout(initWebAPi, 1);
                    }
                    var script = document.createElement("script");
                    script.src = "https://apis.google.com/js/client.js?onload=onGapiLoadCallback";
                    document.getElementsByTagName('head')[0].appendChild(script);
                }
                else {
                    initWebAPi();
                }
            }
        },

        /**
         * Returns a Cocoon SocialGaming interface for the Google Play Games Extension.
         * You can use the Google Play Games extension in two ways, with the official SDK API equivalent or with the CocoonJS Social API abstraction.
         * @memberof Cocoon.Social.GooglePlayGames
         * @function getSocialInterface         
         * @see Cocoon.Social.Interface
         * @returns {Cocoon.Social.Interface}
         */
        getSocialInterface: function() {

            if (!this.initialized) {
                throw "You must call init() before getting the Social Interface";
            }
            if (!this.socialService) {
                this.socialService = new Cocoon.Social.SocialGamingServiceGooglePlayGames(this);
            }
            return this.socialService;
        },

        /**
         * Returns a Cocoon Multiplayer interface for the Game Center Extension.
         * @memberof Cocoon.Social.GooglePlayGames
         * @function getMultiplayerInterface         
         * @returns {Cocoon.Multiplayer.MultiplayerService}
         */
        getMultiplayerInterface: function() {
            return Cocoon.Multiplayer.GooglePlayGames;
        },

        /**
         * Return a Cocoon Multiplayer interface for the Game Center Extension.
         * @memberof Cocoon.Social.GooglePlayGames
         * @function getMultiplayerInterface         
         * @returns {Cocoon.Multiplayer.MultiplayerService}
         * @private 
         * @deprecated
         */        
        share: function() {

            window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;

        }

    };

    extension.GooglePlayGamesAuthExtension = function(extension) {
        this.extension = extension;
        return this;
    }

    extension.GooglePlayGamesAuthExtension.prototype = {
        /**
         * Initiates the OAuth 2.0 authorization process.
         * The browser displays a popup window prompting the user authenticate and authorize.
         * After the user authorizes, the popup closes and the callback function fires.
         * @param {object} params A key/value map of parameters for the request (client_id, inmediate, response_type, scope)
         * @param {function} callback The function to call once the login process is complete. The function takes an OAuth 2.0 token object as its only parameter.
         * @private
         */

        authorize: function(params, callback) {
            var me = this;
            if (this.extension.nativeAvailable) {
                Cocoon.callNative(this.extension.nativeExtensionName, "authorize", [params, function(response, error) {
                    me.extension.token = fromSessionToAuthTokenObject(response,error);
                    if (callback) {
                        callback(me.extension.token);
                    }
                }], true);
            }
            else {
                gapi.auth.authorize(params, function(response){
                    me.extension.token = response;
                    me.extension.onSessionChanged.notifyEventListeners(response, response ? response.error : null);
                    if (callback)
                        callback(response);
                });
            }
        },

        /**
         * Logs the user out of the application
         * @param callback
         */
        disconnect: function(callback) {

            if (this.extension.nativeAvailable) {
                Cocoon.callNative(this.extension.nativeExtensionName, "disconnect", [callback], true);
            }
            else {
                //TODO
                if (callback)
                    callback({error: "Not implemented yet"});
            }
        },

        /**
         *  Initializes the authorization feature. Call this when the client loads to prevent popup blockers from blocking the auth window on gapi.auth.authorize calls.
         *  @param {Function} callback A callback to execute when the auth feature is ready to make authorization calls
         */
        init: function(callback) {

            if (this.extension.nativeAvailable) {
                callback();
            }
            else {
                gapi.auth.init(callback);
            }
        },

        /**
         * Retrieves the OAuth 2.0 token for the application.
         */
        getToken: function() {
            if (this.extension.nativeAvailable) {
                return this.extension.token;
            }
            else {
                return gapi.auth.getToken();
            }
        },
        /*
         * Retrieves the OAuth 2.0 token for the application.
         */

        setToken: function(token) {
            if (this.extension.nativeAvailable) {
                this.extension.token = token;
            }
            else {
                gapi.auth.setToken(token);
            }
        }
    }


    extension.GooglePlayGamesClientExtension = function(extension) {
        this.extension = extension;
        return this;
    }

    extension.GooglePlayGamesClientExtension.prototype = {

        /**
         * Sets the API key for the application, which can be found in the Developer Console. Some APIs require this to be set in order to work.
         * @param apiKey The API key to set.
         */
        setApiKey: function(apiKey) {
            if (this.extension.nativeAvailable) {
                Cocoon.callNative(this.extension.nativeExtensionName, "setApiKey", [apiKey],true);
            }
            else {
                gapi.client.setApiKey(apiKey);
            }
        },

        /**
         * Creates a HTTP request for making RESTful requests.
         * @param {object} args (More info: https://developers.google.com/api-client-library/javascript/reference/referencedocs#gapiclientrequest)
         * @return {object} If no callback is supplied, a request object is returned. The request can then be executed using gapi.client.HttpRequest.execute(callback).
         */
        request: function(args) {
            if (this.extension.nativeAvailable) {
                if (args.callback) {
                    Cocoon.callNative(this.extension.nativeExtensionName, "request", [args, function(response,error){
                        var result = response;
                        if (error) {
                            result = response || {};
                            result.error = error;
                        }
                        args.callback(result);
                    }],true);
                    return null;
                }
                else {
                    var me = this;
                    //return a function to mimic the HttpRequest class
                    var httpRequest =  {
                        execute: function(callback) {
                            Cocoon.callNative(me.extension.nativeExtensionName, "request", [args, function(response, error){
                                var result = response;
                                if (error) {
                                    result = response || {};
                                    result.error = error;
                                }
                                callback(result);
                            }],true);
                        }
                    };
                    return httpRequest;
                }
            }
            else {
                return gapi.client.request(args);
            }
        }
    }


    extension.GooglePlayGames = new Cocoon.Social.GooglePlayGamesExtension();

    /**
     * @ignore
     */
    function fromSessionToAuthTokenObject(response, error) {
        var obj = response || {};
        return {
            access_token: response.access_token,
            state: response.state,
            error: error,
            expires_in: response.expirationDate ? response.expirationDate - Date.now() : 0,
            player_id: response.playerId
        }
    }


    extension.SocialGamingServiceGooglePlayGames = function (apiObject) {
        Cocoon.Social.SocialGamingServiceGooglePlayGames.superclass.constructor.call(this);
        this.gapi = apiObject;
        var me = this;

        this.gapi.onSessionChanged.addEventListener(function(session){
            var obj = session || {};
            me.onLoginStatusChanged.notifyEventListeners(!!obj.access_token, obj.error);
        });

        return this;
    }

    extension.SocialGamingServiceGooglePlayGames.prototype =  {

        isLoggedIn: function() {
            return (this.gapi.token && this.gapi.token.access_token) ? true: false;
        },
        login : function(callback) {
            var me = this;
            this.gapi.auth.authorize({client_id:this.gapi.settings.clientId, scope: this.gapi.defaultScopes}, function(response) {
                if (callback) {
                    callback(me.isLoggedIn(),response.error);
                }
            });
        },
        logout: function(callback) {
            this.gapi.auth.disconnect(callback);
        },
        getLoggedInUser : function() {
            return this.gapi.currentPlayer ? fromGPUserToCocoonUser(this.gapi.currentPlayer) : null;
        },
        requestUser: function(callback, userId) {
            var playerId = userId || "me";
            this.gapi.client.request({path: this.gapi.gamesAPI + "/players/" + playerId, callback: function(response) {
                var user = response && !response.error ? fromGPPlayerToCocoonUser(response) : null;
                callback(user, response.error);
            }});
        },
        requestUserImage: function(callback, userID, imageSize) {
            this.requestUser(function(user, error){
                if (user && user.userImage) {
                    var pixelSize = fromImageSizeToGPSize(imageSize || Cocoon.Social.ImageSize.MEDIUM);
                    if (user.userImage.indexOf("sz=") ===  -1) {
                        user.userImage+="?sz=" + pixelSize;
                    }
                    else {
                        user.userImage = user.userImage.replace(/sz=\d+/g,"sz=" + pixelSize);
                    }
                }
                callback(user ? user.userImage : null, error);
            }, userID);

        },
        requestFriends: function(callback, userId) {
            var params = { orderBy: "best"};
            var playerId = userId || "me";
            this.gapi.client.request({path: this.gapi.plusAPI + "/people/" + playerId + "/people/visible", params: params, callback: function(response) {
                if (response && !response.error) {
                    var friends = [];
                    for (var i = 0; i< response.items.length; ++i) {
                        friends.push(fromGPPersonToCocoonUser(response.items[i]));
                    }
                    callback(friends);
                }
                else {
                    callback([], response ? response.error : null);
                }
            }});
        },

        publishMessage: function(message, callback) {
            if (callback)
                callback("Not supported... use publishMessageWithDialog method instead");
        },

        publishMessageWithDialog: function(message, callback) {

            if (this.gapi.nativeAvailable) {
                var params = {
                    prefilledText: message.message,
                    mediaUrl: message.mediaURL,
                    mediaTitle: message.linkCaption,
                    mediaDescription: message.linkText,
                    url: message.linkURL
                }

                Cocoon.callNative(this.gapi.nativeExtensionName, "shareMessage", [params, callback], true)
            }
            else {

                var me = this;
                var share = function() {
                    var options = {
                        contenturl: 'https://plus.google.com/pages/',
                        contentdeeplinkid: '/pages',
                        clientid: me.gapi.settings.clientId,
                        cookiepolicy: 'single_host_origin',
                        prefilltext: message.message,
                        calltoactionlabel: 'CREATE',
                        calltoactionurl: 'http://plus.google.com/pages/create',
                        calltoactiondeeplinkid: '/pages/create'
                    };

                    gapi.interactivepost.render('sharePost', options);
                }

                if (!gapi.interactivepost) {
                    var script = document.createElement('script'); script.type = 'text/javascript'; script.async = true;
                    script.src = 'https://apis.google.com/js/plusone.js';
                    script.onload = function() {
                        share();
                    }
                    document.getElementsByTagName('head')[0].appendChild(script);
                }
                else {
                    share();
                }
            }
        },

        requestScore: function(callback, params) {
            params = params || {};
            var playerId = params.userID || "me";
            var leaderboardID = params.leaderboardID || this.gapi.settings.defaultLeaderboard;
            if (!leaderboardID)
                throw "leaderboardID not provided in the params. You can also set the default leaderboard in the init method";

            this.gapi.client.request({path: this.gapi.gamesAPI + "/players/" + playerId + "/leaderboards/" + leaderboardID + "/scores/ALL_TIME", callback: function(response) {
                if (response && response.error) {
                    callback(null, response.error)
                }
                else if (response && response.items && response.items.length > 0) {
                    var item = response.items[0];
                    var data = new Cocoon.Social.Score(playerId, item.scoreValue,"","", item.leaderboard_id);
                    callback(data, null);
                }
                else {
                    //No score has been submitted yet for the user
                    callback(null,null);
                }
            }});

        },

        submitScore: function(score, callback, params) {
            params = params || {};
            var leaderboardID = params.leaderboardID || this.gapi.settings.defaultLeaderboard;
            if (!leaderboardID)
                throw "leaderboardID not provided in the params. You can also set the default leaderboard in the init method";


            this.gapi.client.request({path: this.gapi.gamesAPI + "/leaderboards/" + leaderboardID + "/scores",
                                      method: "POST", params:{score: score}, callback: function(response) {
                    if (callback) {
                        callback(response ? response.error : null);
                    }
            }});

        },

        showLeaderboard : function(callback, params) {
            params = params || {};
            var leaderboardID = params.leaderboardID || this.gapi.settings.defaultLeaderboard;
            if (!leaderboardID)
                throw "leaderboardID not provided in the params. You can also set the default leaderboard in the init method";

            var ios = /(iPad|iPhone|iPod)/ig.test( navigator.userAgent );
            if (!ios && this.gapi.nativeAvailable) {
                var timeScope = params.timeScope || 0;
                Cocoon.callNative(this.gapi.nativeExtensionName, "showLeaderboard", [leaderboardID, timeScope, callback], true);
            }
            else {
                if (!this._leaderboardsTemplate)
                    throw "Please, provide a html template for leaderboards with the setTemplates method";
                var dialog = new Cocoon.Widget.WebDialog();
                var callbackSent = false;
                dialog.show(this._leaderboardsTemplate, function(error) {
                    dialog.closed = true;
                    if (!callbackSent && callback)
                        callback(error);
                });
                var me = this;
                var collection = params.friends ? "SOCIAL" : "PUBLIC";
                var timeSpan = "ALL_TIME";
                if (params.timeScope === Cocoon.Social.TimeScope.WEEK) {
                    timeSpan = "WEEKLY";
                }
                else if (params.timeScope === Cocoon.Social.TimeScope.TODAY) {
                    timeSpan = "DAILY";
                }
                this.gapi.client.request({path: this.gapi.gamesAPI + "/leaderboards/" + leaderboardID + "/window/" + collection,
                    method: "GET", params:{timeSpan: timeSpan}, callback: function(response) {
                        if (dialog.closed)
                            return;
                        if (response.error) {
                            if (callback) {
                                callbackSent = true;
                                callback(response.error);
                                dialog.close();
                            }
                            return;
                        }
                        var scores = [];
                        var items = [];
                        if (response && response.items) {
                            items = response.items.slice(0);
                        }
                        if (response && response.playerScore) {
                            items.push(response.playerScore);
                        }
                        for (var i = 0; i< items.length; ++i) {
                            var item = items[i];
                            var score = fromGPScoreToCocoonScore(item, leaderboardID);
                            score.imageURL+="?sz=50";
                            score.position = item.scoreRank || i + 1;
                            score.me = false;
                            scores.push(score);
                        }
                        var js = "addScores(" + JSON.stringify(scores) + ")";
                        dialog.eval(js);
                    }});
            }
        },

        //internal utility function
        prepareAchievements: function(reload, callback) {
            if (!this._cachedAchievements || reload) {
                var me = this;
                this.gapi.client.request({path: this.gapi.gamesAPI + "/achievements", callback: function(response) {
                    if (response && !response.error) {
                        var achievements = [];
                        if (response && response.items) {
                            for (var i = 0; i < response.items.length; i++) {
                                achievements.push(fromGPAchievementToCocoonAchievement(response.items[i]))
                            }
                        }
                        me.setCachedAchievements(achievements);
                        callback(achievements, null);
                    }
                    else {
                        callback([], response ? response.error : null);
                    }
                }});
            }
            else {
                callback(this._cachedAchievements, null);
            }
        },

        requestAllAchievements : function(callback) {
            this.prepareAchievements(true, callback);
        },

        requestAchievements : function(callback, userID) {
            var me = this;
            this.prepareAchievements(false, function(allAchievements, error){
                if (error) {
                    callback([], error);
                    return;
                }
                var playerID = userID || "me";
                me.gapi.client.request({path: me.gapi.gamesAPI + "/players/" + playerID + "/achievements",
                                        params: {state: "UNLOCKED"}, callback: function(response) {
                    if (response && !response.error) {
                        var achievements = [];
                        if (response.items) {
                            for (var i = 0; i < response.items.length; i++) {
                                var ach = me.findAchievement(response.items[i].id);
                                if (ach)
                                    achievements.push(ach);
                            }
                        }
                        callback(achievements, null);
                    }
                    else {
                        callback([], response ? response.error : null);
                    }
                }});

            });
        },
        submitAchievement: function(achievementID, callback) {
            if (achievementID === null || typeof achievementID === 'undefined')
                throw "No achievementID specified";
            var achID = this.translateAchievementID(achievementID);
            if (this.gapi.nativeAvailable) {
                //native API allows to show a native notification view. (REST API doesn't)
                var showNotification = !!this.gapi.settings.showAchievementNotifications;
                Cocoon.callNative(this.gapi.nativeExtensionName, "unlockAchievement", [achID, showNotification, callback], true);
            }
            else {
                //REST api
                this.gapi.client.request({path: this.gapi.gamesAPI + "/achievements/" + achID + "/unlock",
                    method: "POST", callback: function(response) {
                        if (callback) {
                            callback(response ? response.error : null);
                        }
                    }});
            }
        },
        resetAchievements : function(callback) {
            this.gapi.client.request({path: "/games/v1management/achievements/reset",
                method: "POST", callback: function(response) {
                    if (callback) {
                        callback(response ? response.error : null);
                    }
                }});
        },
        showAchievements : function(callback) {
            var ios = /(iPad|iPhone|iPod)/ig.test( navigator.userAgent );
            if (!ios && this.gapi.nativeAvailable) {
                Cocoon.callNative(this.gapi.nativeExtensionName, "showAchievements", [callback], true);
            }
            else {
                Cocoon.Social.SocialGamingServiceGooglePlayGames.superclass.showAchievements.call(this);
            }
        }
    }

    Cocoon.extend(Cocoon.Social.SocialGamingServiceGooglePlayGames, Cocoon.Social.SocialGamingService);


    /**
     *@ignore
     */
    function fromGPPlayerToCocoonUser (gpPlayer) {
        return new Cocoon.Social.User (gpPlayer.playerId, gpPlayer.displayName, gpPlayer.avatarImageUrl);
    }
    /**
     *@ignore
     */
    function fromGPPersonToCocoonUser (gpUser) {
        var avatar = gpUser.image ? gpUser.image.url : "";
        avatar = avatar.replace(/sz=\d+/g,"sz=100");
        return new Cocoon.Social.User (gpUser.id, gpUser.displayName, avatar);
    }
    /**
     *@ignore
     */
    function fromImageSizeToGPSize (imageSize) {
        if (imageSize === Cocoon.Social.ImageSize.THUMB) {
            return 100;
        }
        else if (imageSize === Cocoon.Social.ImageSize.MEDIUM) {
            return 200;
        }
        else if (imageSize === Cocoon.Social.ImageSize.LARGE) {
            return 512;
        }
    }
    /**
     *@ignore
     */
    function fromGPAchievementToCocoonAchievement(gpItem) {
        var result = new Cocoon.Social.Achievement (
            gpItem.id,
            gpItem.name,
            gpItem.description,
            gpItem.revealedIconUrl,
            0
        );
        result.gpAchievementData = gpItem;
        return result;
    }
    /**
     *@ignore
     */
    function fromGPScoreToCocoonScore(gpItem, leaderboardID) {
        return new Cocoon.Social.Score(gpItem.player.playerId, gpItem.scoreValue, gpItem.player.displayName, gpItem.player.avatarImageUrl, leaderboardID);
    }
    
    return extension;
});
;/**
 * This namespace represents all the basic functionalities available in the CocoonJS extension API.
 *
 * <div class="alert alert-success">
 *   Here you will find a demo about this namespace: <a href="https://github.com/ludei/cocoonjs-demos/tree/Multiplayer">Multiplayer demo</a>.
 *</div>
 *
 * <div class="alert alert-warning">
 *    <strong>Warning!</strong> This JavaScript extension requires some configuration parameters on the <a href="https://ludei.zendesk.com/hc/en-us">cloud compiler</a>!
 * </div>
 * @namespace Cocoon.Social.GameCenter
 */
Cocoon.define("Cocoon.Social" , function(extension){

    extension.GameCenterExtension = function() {
        this.nativeExtensionName = "IDTK_SRV_GAMECENTER";
        this.extensionName = "Social.GameCenter";
        this.nativeAvailable =  (!!window.ext) && (!!window.ext[this.nativeExtensionName]);

        var me = this;
        if (this.nativeAvailable) {
            this.onGameCenterLoginStateChanged = new Cocoon.EventHandler(this.nativeExtensionName, this.extensionName, "onGameCenterLoginStateChanged");

            this.onGameCenterLoginStateChanged.addEventListener(function(localPlayer,error){
                me._currentPlayer = localPlayer;
            });
        }
        return this;
    };

    extension.GameCenterExtension.prototype = {

        _currentPlayer: null,

        /**
         * This namespace represents all the basic functionalities available in the CocoonJS extension API.
         * <div class="alert alert-warning">
         *    <strong>Warning!</strong> This JavaScript extension requires some configuration parameters on the <a href="https://ludei.zendesk.com/hc/en-us">cloud compiler</a>!.
         * </div>
         */

         /**
         * Returns a Cocoon Social Interface for the Game Center Extension.
         * You can use the Game Center extension in two ways, with 1:1 official API equivalent or with the CocoonJS API abstraction.
         * @function getSocialInterface
         * @memberOf Cocoon.Social.GameCenter
         * @see Cocoon.Social.Interface
         * @returns {Cocoon.Social.Interface}
         */
        getSocialInterface: function() {
            if (!this._socialService) {
                this._socialService = new Cocoon.Social.SocialGamingServiceGameCenter(this);
            }
            return this._socialService;
        },

        /**
         * Returns a Cocoon Multiplayer interface for the Game Center Service.
         * @function getMultiplayerInterface
         * @memberOf Cocoon.Social.GameCenter
         * @returns {Cocoon.Multiplayer.MultiplayerService}
         */
        getMultiplayerInterface: function() {
            return Cocoon.Multiplayer.GameCenter;
        },

        isLoggedIn: function() {
            return this._currentPlayer && this._currentPlayer.isAuthenticated;
        },

        /**
         * Authenticates the user.
         * @function login
         * @memberOf Cocoon.Social.GameCenter          
         * @params {function} callback The callback function. Response params: Cocoon.Social.GameCenter.LocalPlayer and error.
         */
        login: function(callback) {
            var me = this;
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "login", [function(response, error) {
                    me._currentPlayer = response;
                    if (callback) {
                        callback(response,error);
                    }
                }], true);
            }
            else {
                throw "Game Center not available";
            }
        },

        /**
         * Synchronous accessor for the current authResponse.
         * @function getLocalPlayer
         * @memberOf Cocoon.Social.GameCenter             
         * @returns {Cocoon.Social.GameCenter.LocalPlayer} Current Local Player data.
         */
        getLocalPlayer: function() {
            if (this._currentPlayer)
                return this._currentPlayer;
            if (this.nativeAvailable) {
                this._currentPlayer = Cocoon.callNative(this.nativeExtensionName, "getLocalPlayer", []);
                return this._currentPlayer;
            }
            else {
                throw "Game Center not available";
            }
        },

        /**
         * Loads the players of the provided identifiers.
         * @function loadPlayers
         * @memberOf Cocoon.Social.GameCenter          
         * @param {array} playerIDs Array of player identifiers.
         * @param {function} callback The callback function. It receives the following parameters: 
         * - Array of {@link Cocoon.Social.GameCenter.Player}. 
         * - Error.
         */
        loadPlayers: function(playerIDs, callback) {
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "loadPlayers", [playerIDs, callback], true);
            }
            else {
                throw "Game Center not available";
            }
        },

        /**
         * Loads the friends of the current logged in user.
         * @function loadFriends
         * @memberOf Cocoon.Social.GameCenter          
         * @param {function} callback The callback function. It receives the following parameters: 
         * - Array of {@link Cocoon.Social.GameCenter.Player}. 
         * - Error. 
         */
        loadFriends: function(callback) {
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "loadFriends", [callback], true);
            }
            else {
                throw "Game Center not available";
            }
        },

        /**
         * Loads the earned achievements for the current logged in user.
         * @function loadAchievements
         * @memberOf Cocoon.Social.GameCenter 
         * @param {function} callback The callback function. It receives the following parameters: 
         * - Array of {@link Cocoon.Social.GameCenter.Achievement}. 
         * - Error.
         */
        loadAchievements: function(callback) {
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "loadAchievements", [callback], true);
            }
            else {
                throw "Game Center not available";
            }
        },

        /**
         * Loads the application achievement descriptions.
         * @function loadAchievementDescriptions
         * @memberOf Cocoon.Social.GameCenter         
         * @param {function} callback The callback function. It receives the following parameters: 
         * - Array of {@link Cocoon.Social.GameCenter.Achievement}. 
         * - Error.
         */
        loadAchievementDescriptions: function(callback) {
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "loadAchievementDescriptions", [callback], true);
            }
            else {
                throw "Game Center not available";
            }
        },

        /**
         * Load the application achievement descriptions.
         * @function loadScores
         * @memberOf Cocoon.Social.GameCenter           
         * @param {function} callback The callback function. It receives the following parameters: 
         * - {@link Cocoon.Social.GameCenter.Leaderboard}. 
         * - Error. 
         * @param {Cocoon.Social.GameCenter.Leaderboard} [query] Optional query parameters.
         */
        loadScores: function(callback, query) {
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "loadScores", [query,callback], true);
            }
            else {
                throw "Game Center not available";
            }
        },

        /**
         * Report user score to the server.
         * @function submitScore
         * @memberOf Cocoon.Social.GameCenter          
         * @param {Cocoon.Social.GameCenter.Score} score Definition of the score and it's category (leaderboardID).
         * If no category is specified the default one is used.
         * @param {function} callback The callback function. Response params: error.
         */
        submitScore: function(score, callback) {
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "submitScore", [score,callback], true);
            }
            else {
                throw "Game Center not available";
            }
        },

        /**
         * Reports user earned achievements to the server.
         * @function submitAchievements
         * @memberOf Cocoon.Social.GameCenter          
         * @param {array} achievements - Array of {@link Cocoon.Social.GameCenter.Achievement} objects.
         * @param {function} callback The callback function. Response params: error.
         */
        submitAchievements: function(achievements, callback) {
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "submitAchievements", [achievements,callback], true);
            }
            else {
                throw "Game Center not available";
            }
        },

        /**
         * Resets all the achievements of the current logged in user.
         * @function resetAchievements
         * @memberOf Cocoon.Social.GameCenter  
         * @param {function} [callback] The callback function. Response params: error.
         */
        resetAchievements : function(callback) {
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "resetAchievements", [callback], true);
            }
            else {
                throw "Game Center not available";
            }
        },

        /**
         * Shows a native view with the standard user interface for achievements.
         * @function showAchievements
         * @memberOf Cocoon.Social.GameCenter
         * @param {function} callback The callback function when the view is closed by the user. Response params: error
         */
        showAchievements: function(callback) {
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "showAchievements", [callback], true);
            }
            else {
                throw "Game Center not available";
            }
        },

        /**
         * Shows a native view with the standard user interface for leaderboards.
         * @function showLeaderboards
         * @memberOf Cocoon.Social.GameCenter
         * @param {function} callback The callback function when the view is closed by the user. Response params: error
         * @param {Cocoon.Social.GameCenter.Leaderboard} [query] Optional parameters
         */
        showLeaderboards: function(callback, query) {
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "showLeaderboards", [query, callback], true);
            }
            else {
                throw "Game Center not available";
            }
        }
    };

    extension.GameCenter = new extension.GameCenterExtension();

    /**
    * The object that represents the information of a Game Center player.
    * @memberof Cocoon.Social.GameCenter
    * @name Cocoon.Social.GameCenter.Player
    * @property {object} Cocoon.Social.GameCenter.Player - The object itself
    * @property {string} Cocoon.Social.GameCenter.Player.playerID The identifier of the player.
    * @property {string} Cocoon.Social.GameCenter.Player.alias The alias of the player.
    * @property {boolean} Cocoon.Social.GameCenter.Player.isFriend True if the user is friend of the local player.
    */
    extension.GameCenter.Player = function() {

        this.playerID = "";

        this.alias = "";

        this.isFriend = false;
    }

    /**
    * The object that represents the information of a Game Center local player.
    * @memberof Cocoon.Social.GameCenter
    * @name Cocoon.Social.GameCenter.LocalPlayer
    * @property {object} Cocoon.Social.GameCenter.LocalPlayer - The object itself
    * @property {string} Cocoon.Social.GameCenter.LocalPlayer.playerID The identifier of the player.
    * @property {string} Cocoon.Social.GameCenter.LocalPlayer.alias The alias of the player.
    * @property {boolean} Cocoon.Social.GameCenter.LocalPlayer.isAuthenticated Indicates the authentication state of the current player.
    */
    extension.GameCenter.LocalPlayer = function() {

        this.playerID = "";

        this.alias = "";

        this.isAuthenticated = false;
    }

    /**
    * The object that represents an earned achievement by the user.
    * @memberof Cocoon.Social.GameCenter
    * @name Cocoon.Social.GameCenter.Achievement
    * @property {object} Cocoon.Social.GameCenter.Achievement - The object itself
    * @property {string} Cocoon.Social.GameCenter.Achievement.identifier The id of the achievement.
    * @property {number} Cocoon.Social.GameCenter.Achievement.percentComplete Percentage of achievement complete (from 0 to 100).
    * @property {number} Cocoon.Social.GameCenter.Achievement.lastReportedDate Date the achievement was last reported (unix time).
    */
    extension.GameCenter.Achievement = function(identifier, percentComplete) {

        this.identifier = identifier;

        this.percentComplete = percentComplete;

        this.lastReportedDate = 0;
    }

    /**
    * The object that represents an earned achievement by the user.
    * @memberof Cocoon.Social.GameCenter
    * @name Cocoon.Social.GameCenter.AchievementDescription
    * @property {object} Cocoon.Social.GameCenter.AchievementDescription - The object itself
    * @property {string} Cocoon.Social.GameCenter.AchievementDescription.identifier The identifier of the achievement.
    * @property {string} Cocoon.Social.GameCenter.AchievementDescription.title The title of the achievement.
    * @property {string} Cocoon.Social.GameCenter.AchievementDescription.achievedDescription The description for an achieved achievement.
    * @property {string} Cocoon.Social.GameCenter.AchievementDescription.unachievedDescription The description for an unachieved achievement.
    * @property {number} Cocoon.Social.GameCenter.AchievementDescription.maximumPoints The maximum points of the achievement.
    */
    extension.GameCenter.AchievementDescription = function() {

        this.identifier = "";

        this.title = "";

        this.achievedDescription = "";

        this.unachievedDescription = "";

        this.maximumPoints = 0;
    }

    /**
    * The object that represents a score in the leaderboards.
    * @memberof Cocoon.Social.GameCenter
    * @name Cocoon.Social.GameCenter.Score
    * @property {object} Cocoon.Social.GameCenter.Score - The object itself
    * @property {string} Cocoon.Social.GameCenter.Score.userID The identifier of the player that recorded the score.
    * @property {number} Cocoon.Social.GameCenter.Score.score The score value as a 64bit integer.
    * @property {string} Cocoon.Social.GameCenter.Score.userName The name of the user.
    * @property {string} Cocoon.Social.GameCenter.Score.imageURL imageURL The url of the user image.
    * @property {string} Cocoon.Social.GameCenter.Score.leaderboardID Leaderboard category.
    * @property {number} Cocoon.Social.GameCenter.Score.rank The rank of the player within the leaderboard.
    */
    extension.GameCenter.Score = function(userID, score, userName, imageURL, leaderboardID, originalScoreObject)
    {

        this.userID = userID;

        this.score = score || 0;

        this.userName = userName;

        this.imageURL = imageURL;

        this.leaderboardID = leaderboardID;

        this.rank = originalScoreObject.rank;

        this.originalScoreObject = originalScoreObject;

        return this;
    };


    /**
    * The object that represents the set of high scores for the current game.
    * @memberof Cocoon.Social.GameCenter
    * @name Cocoon.Social.GameCenter.Leaderboard
    * @property {object} Cocoon.Social.GameCenter.Leaderboard - The object itself
    * @property {string} Cocoon.Social.GameCenter.Leaderboard.category The category of the leaderboard (query parameter).
    * @property {array} Cocoon.Social.GameCenter.Leaderboard.playerIDs Player identifiers array (query parameter).
    * @property {Cocoon.Social.GameCenter.TimeScope} Cocoon.Social.GameCenter.Leaderboard.timeScope Time scope (query parameter).
    * @property {Cocoon.Social.GameCenter.PlayerScope} Cocoon.Social.GameCenter.Leaderboard.playerScope Player scope (query parameter).
    * @property {number} Cocoon.Social.GameCenter.Leaderboard.rangeStart Leaderboards start at index 1 and the length should be less than 100 (query parameter).
    * @property {number} Cocoon.Social.GameCenter.Leaderboard.rangeLength Leaderboards start at index 1 and the length should be less than 100 (query parameter).
    * @property {array} Cocoon.Social.GameCenter.Leaderboard.scores Scores array (response parameter).
    * @property {Cocoon.Social.GameCenter.Score} Cocoon.Social.GameCenter.Leaderboard.localPlayerScore Local player score (response parameter).
    * @property {string} Cocoon.Social.GameCenter.Leaderboard.localizedTitle Localized category title.
    */
    extension.GameCenter.Leaderboard = function(category, playerIDs, timeScope, playerScope, rangeStart, rangeLength) {
        
        this.category = category;
       
        this.playerIDs = playerIDs;
        
        this.timeScope = timeScope;
    
        this.playerScope = playerScope;

        this.rangeStart = rangeStart;

        this.rangeLength = rangeLength;

        this.scores = [];

        this.localPlayerScore = [];

        this.localizedTitle = localizedTitle;
    }

    /**
    * This object represents the possible Time Scopes for a leaderboard query.
    * @memberof Cocoon.Social.GameCenter
    * @name Cocoon.Social.GameCenter.TimeScope
    * @property {object} Cocoon.Social.GameCenter.TimeScope - The object itself
    * @property {string} Cocoon.Social.GameCenter.TimeScope.TODAY Today.
    * @property {string} Cocoon.Social.GameCenter.TimeScope.WEEK A week.
    * @property {string} Cocoon.Social.GameCenter.TimeScope.ALL_TIME All registered time.
    */
    extension.GameCenter.TimeScope =
    {
        TODAY: 0,
        WEEK: 1,
        ALL_TIME:2
    };

    /**
    * This object represents the possible Player Scopes for a leaderboad query.
    * @memberof Cocoon.Social.GameCenter
    * @name Cocoon.Social.GameCenter.PlayerScope
    * @property {object} Cocoon.Social.GameCenter.PlayerScope - The object itself
    * @property {string} Cocoon.Social.GameCenter.PlayerScope.GLOBAL Global.
    * @property {string} Cocoon.Social.GameCenter.PlayerScope.FRIENDS Friends.
    */
    extension.GameCenter.PlayerScope =
    {
        GLOBAL: 0,
        FRIENDS: 1
    };


    //Social API Interface
    extension.SocialGamingServiceGameCenter = function(gcExtension) {
        Cocoon.Social.SocialGamingServiceGameCenter.superclass.constructor.call(this);
        this.gc = gcExtension;
        var me = this;
        this.gc.onGameCenterLoginStateChanged.addEventListener(function(localPlayer, error){
            me.onLoginStatusChanged.notifyEventListeners(localPlayer.isAuthenticated,error);
        });
        return this;
    }

    extension.SocialGamingServiceGameCenter.prototype =  {

        _cachedAchievements: null,

        isLoggedIn: function() {
            return this.gc.isLoggedIn();
        },
        login : function(callback) {
            this.gc.login(function(localPlayer, error){
                if (callback)
                    callback(localPlayer.isAuthenticated, error);
            });
        },
        logout: function(callback) {
            if (callback)
                callback({message:"User has to logout from the Game Center APP"});
        },
        getLoggedInUser : function() {
            return fromGCPLayerToCocoonUser(this.gc._currentPlayer ? this.gc._currentPlayer : this.gc.getLocalPlayer());
        },

        requestUser: function(callback, userId) {
            if (userId) {
                this.gc.loadPlayers([userId], function(response, error) {
                    var user = response && response.length ? fromGCPLayerToCocoonUser(response[0]) : null;
                    callback(user, error);
                });
            }
            else {
                var me = this;
                setTimeout(function(){
                    callback(me.getLoggedInUser());
                })
            }
        },
        requestFriends: function(callback, userId) {
            this.gc.loadFriends(function(friends, error){
                var users = [];
                if (friends && friends.length) {
                    for (var i= 0; i< friends.length; ++i) {
                        users.push(fromGCPLayerToCocoonUser(friends[i]));
                    }
                }
                callback(users, error);
            });
        },
        requestScore: function(callback, params) {
            var query = {};
            var options = params || {};
            if (options.leaderboardID)
                query.category = options.leaderboardID;
            query.playerIDs = [options.userID || this.getLoggedInUser().userID];

            this.gc.loadScores(function(response, error) {
                var gcScore = null;
                if (options.userID && response && response.scores && response.scores.length)
                    gcScore = response.scores[0];
                else if (response && response.localPlayerScore)
                    gcScore = response.localPlayerScore;
                var loadedScore = gcScore ? new Cocoon.Social.GameCenter.Score(gcScore.playerID, gcScore.value, "","", gcScore.category, gcScore) : null;
                callback(loadedScore,error);
            }, query);
        },
        submitScore: function(score, callback, params) {
            var options = params || {};
            this.gc.submitScore({value:score, category:options.leaderboardID || ""}, function(error){
                if (callback)
                    callback(error);
            });
        },
        showLeaderboard : function(callback, params) {
            var options = params || {};
            this.gc.showLeaderboards(function(error){
                if (callback)
                    callback(error);
            }, {category:options.leaderboardID || ""});
        },
        //internal utility function
        prepareAchievements: function(reload, callback) {

            if (!this._cachedAchievements || reload) {
                var me = this;
                this.gc.loadAchievementDescriptions(function(response, error){
                    if (error) {
                        callback([],error);
                    }
                    else {
                       var achievements = [];
                       if (response && response.length) {
                           for (var i = 0; i < response.length; i++) {
                               achievements.push(fromGCAchievementDescriptionToCocoonAchievement(response[i]))
                           }
                       }
                       me.setCachedAchievements(achievements);
                       callback(achievements, null);
                    }

                });
            }
            else {
                callback(this._cachedAchievements, null);
            }
        },
        requestAllAchievements : function(callback) {
            this.prepareAchievements(true, callback);
        },
        requestAchievements : function(callback, userID) {
            var me = this;
            this.prepareAchievements(false, function(allAchievements, error){
                if (error) {
                    callback([], error);
                    return;
                }
                me.gc.loadAchievements(function(response, error){
                    if (!error) {
                        var achievements = [];
                        if (response && response.length) {
                            for (var i = 0; i < response.length; i++) {
                                var ach = me.findAchievement(response[i].identifier);
                                if (ach)
                                    achievements.push(ach);
                            }
                        }
                        callback(achievements, null);
                    }
                    else {
                        callback([], response.error);
                    }

                });
            });
        },
        submitAchievement: function(achievementID, callback) {
            if (achievementID === null || typeof achievementID === 'undefined')
                throw "No achievementID specified";
            var achID = this.translateAchievementID(achievementID);
            this.gc.submitAchievements([{identifier:achID, percentComplete:100}], callback);
        },
        resetAchievements : function(callback) {
            this.gc.resetAchievements(callback);
        },
        showAchievements : function(callback) {
            this.gc.showAchievements(function(error){
                if (callback)
                    callback(error);
            });
        }
    };

    Cocoon.extend(extension.SocialGamingServiceGameCenter, extension.SocialGamingService);


    function fromGCPLayerToCocoonUser(player){
        return new Cocoon.Social.User(player.playerID, player.alias);
    }

    function fromGCAchievementDescriptionToCocoonAchievement(ach) {
        return new Cocoon.Social.GameCenter.Achievement(ach.identifier,ach.title, ach.achievedDescription,"", ach.maximumPoints);
    }
    
    return extension;
});
;/**
 * This namespace represents all the basic functionalities available in the CocoonJS extension API.
 *
 * <div class="alert alert-success">
 *   Here you will find a demo about this namespace: <a href="https://github.com/ludei/cocoonjs-demos/tree/Facebook">Facebook demo</a>.
 *</div>
 * 
 * <div class="alert alert-warning">
 *    <strong>Warning!</strong> This JavaScript extension requires some configuration parameters on the <a href="https://ludei.zendesk.com/hc/en-us">cloud compiler</a>!
 * </div>
 * @namespace Cocoon.Social.Facebook
 */
Cocoon.define("Cocoon.Social" , function(extension){

    extension.FacebookExtension = function (){
        this.nativeExtensionName = "IDTK_SRV_FACEBOOK";
        this.extensionName = "Social.Facebook";
        this.nativeAvailable =  (!!window.ext) && (!!window.ext[this.nativeExtensionName]);
        this.Event = new Cocoon.Social.FacebookEvent(this.nativeAvailable);

        var me = this;
        if (this.nativeAvailable) {

            this.onFacebookSessionStateChanged = new Cocoon.EventHandler(this.nativeExtensionName, this.extensionName, "onFacebookSessionStateChanged");

            Cocoon.Social.Facebook = this; //the object it's being created but the addEventListener needs it now
            this.onFacebookSessionStateChanged.addEventListener(function(session, error) {
                var data = fromCocoonFBSessionToFBAPISession(session,error);
                if (session.state == 0) {
                    me.Event.notify("auth.login", data);
                }
                me.Event.notify("auth.authResponseChange", data);
                me.Event.notify("auth.statusChange", data);
            });
        }

        return this;
    };

    extension.FacebookExtension.prototype = {

        _currentSession: null,
        _appId: null,
        _socialService: null,

        /**
        * Initializes the SDK with your app ID. This will let you make calls against the Facebook API. All FB.API methods must be called after FB.init.
        * @memberof Cocoon.Social.Facebook
        * @function init
        * @param {object} options Check available options here: https://developers.facebook.com/docs/reference/javascript/FB.init/
        */
        init: function(options) {
            if (!options || !options.appId) {
                throw "appId must be specified!";
            }

            this._appId = options.appId;

            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "init", [options], true);
            }
            else {
                FB.init(options);
            }

            var me = this;
            this.Event.subscribe("auth.authResponseChange", function(session) {
                me._currentSession = session;
                if (session.authResponse && !session.authResponse.user){
                    me.api("me?fields=username", function(response) {
                        me._currentSession.authResponse.user = response;
                    });
                }
            });
        },

        /**
        * Returns a Cocoon SocialGaming interface for the Facebook Extension.
        * @memberof Cocoon.Social.Facebook
        * @function getSocialInterface
        * @returns {Cocoon.Social.Interface}
        */
        getSocialInterface: function() {

            if (!this._appId) {
                throw "You must call init() before getting the Social Interface";
            }
            if (!this._socialService) {
                this._socialService = new Cocoon.Social.SocialGamingServiceFacebook(this);
            }
            return this._socialService;
        },

        /**
        * Authenticates the user.
        * By default, calling login will attempt to authenticate the user with only the basic permissions.
        * If you want one or more additional permissions, call login with an option object,
        * and set the scope parameter with a comma-separated list of the permissions you wish to request from the user.
        * @memberof Cocoon.Social.Facebook
        * @function login
        * @param {object} options Login options.
        * @params {function} callback The callback function with received session data or error.
        */
        login: function(callback, options) {
            var me = this;
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "login", [options, function(response, error) {
                    me._currentSession = fromCocoonFBSessionToFBAPISession(response,error);
                    if (callback) {
                        callback(me._currentSession);
                    }

                }], true);
            }
            else {
                FB.login(function(response){
                    me._currentSession = response;
                    if (callback)
                        callback(response);
                }, options);
            }

        },

        /**
        * Logs the user out of your application.
        * You will need to have a valid access token for the user in order to call the function.
        * @memberof Cocoon.Social.Facebook
        * @function logout
        * @param {function} callback Called when the user is logged out.
        */       
        logout: function(callback) {
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "logout", [function(response, error) {
                    if (callback) {
                        callback(fromCocoonFBSessionToFBAPISession(response, error));
                    }

                }],true);
            }
            else {
                FB.logout(function(response){
                    if (callback) {
                        callback(response);
                    }
                });
            }

        },

        /**
        * Synchronous accessor for the current authResponse.
        * @memberof Cocoon.Social.Facebook
        * @function getAuthResponse        
        * @returns {object} current Facebook session data.
        */        
        getAuthResponse: function() {

            if (this.nativeAvailable) {
                var response = Cocoon.callNative(this.nativeExtensionName, "getFacebookSession", []);
                return fromCocoonFBSessionToFBAPISession(response);
            }
            else {
                return FB.getAuthResponse();
            }

        },

        /**
        * Allows you to determine if a user is logged in to Facebook and has authenticated your app.
        * There are three possible states for a user:
        * 1. The user is logged into Facebook and has authenticated your application (connected).
        * 2. The user is logged into Facebook but has not authenticated your application (not_authorized).
        * 3. The user is not logged into Facebook at this time and so we don't know if they've authenticated your application or not.
        * @memberof Cocoon.Social.Facebook
        * @function getLoginStatus           
        * @param {function} callback The callback function.
        * @param {boolean} force Force reloading the login status (default false).
        */
        getLoginStatus: function(callback, force) {
            if (this.nativeAvailable) {

                var me = this;
                setTimeout(function(){
                    var response = Cocoon.callNative(me.nativeExtensionName, "getFacebookSession", []);
                    if (callback) {
                        callback(fromCocoonFBSessionToFBAPISession(response));
                    }

                },50);
            }
            else {
                FB.getLoginStatus(callback, force);
            }

        },

        /**
        * Makes API calls to the Graph API.
        * @memberof Cocoon.Social.Facebook
        * @function api       
        * @param path The Graph API url path.
        * @param method The http method (default "GET").
        * @param params The parameters for the query.
        * @param cb The callback function to handle the response.
        */       
        api: function(path, method, params, cb ) {

            if (this.nativeAvailable) {
                var openGraph = arguments[0];
                var httpMethod = arguments.length > 3 ? arguments[1] : "GET";
                var options = null;
                if (arguments.length == 3) options = arguments[1];
                if (arguments.length == 4) options = arguments[2];
                var callback = arguments.length > 1 ? arguments[arguments.length -1 ] : function(){};

                return Cocoon.callNative(this.nativeExtensionName, "api", [openGraph, httpMethod, options, callback], true);
            }
            else {
                FB.api(path,method,params,cb);
            }
        },

        /**
        * A generic method for triggering Dialogs which allow the user to take some action.
        * @memberof Cocoon.Social.Facebook
        * @function ui        
        * @param params The required arguments vary based on the method being used, but specifying the method itself is mandatory.
        * @param cb Callback function to handle the result. Not all methods may have a response.
        */
        ui: function(params, cb) {

            if (this.nativeAvailable){
                var params = arguments[0];
                var callback = arguments.length > 1 ? arguments[1]: function(){};

                return Cocoon.callNative(this.nativeExtensionName, "ui", [params, callback], true);
            }
            else if (!navigator.isCocoonJS)
            {
                FB.ui(params,cb);
            }
        },

        /**
        * Allows you to ask additional permission from the current ones.
        * @memberof Cocoon.Social.Facebook
        * @function requestAdditionalPermissions.        
        * @param {string} permissionsType "read" or "publish".
        * @param permissions Comma separated Facebook permission names.
        * @param callback Response authResponse callback.
        */
        requestAdditionalPermissions: function(permissionsType, permissions, callback) {
            if (this.nativeAvailable) {

                var permsArray = permissions.split(',');
                Cocoon.callNative(this.nativeExtensionName, "requestAdditionalPermissions", [permissionsType, permsArray, function(session, error){
                    if (callback) {
                        callback(fromCocoonFBSessionToFBAPISession(session,error));
                    }
                }], true);
            }
            else {
                FB.login(callback, {scope:permissions});
            }
        },

        /**
        * Queries Facebook permissions of the current user.
        * @memberof Cocoon.Social.Facebook
        * @function getPermissions 
        * @param callback Handler function which receives a dictionary with the granted permissions.
        */
        getPermissions: function(callback) {
            this.api('me/permissions', function(response) {
                callback(response.data && response.data[0] ? response.data[0] : {});
            });
        },

        /**
        * Presents a dialog in the Facebook application that allows the user to share a status update.
        * If the Facebook Application is not available it does a fallback to a feed dialog.
        * No publish permissions are required.
        * @memberof Cocoon.Social.Facebook
        * @function showShareDialog         
        * @param params Dialog params (description, caption, name, link, picture).
        * @param callback Handler with response data or error.
        */
        showShareDialog: function(params, callback) {
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "showShareDialog", [params, callback], true);
            }
            else {
                params.method = "feed";
                FB.ui(params, callback);
            }
        },

        /**
        * Upload a local image file to Facebook and get response.
        * @memberof Cocoon.Social.Facebook
        * @function uploadPhoto            
        * @param file The local file url to submit to Facebook (For example the one capture with screenCapture API).
        * @param callback Handler to process response with the photoid and other data or the error.
        */
        uploadPhoto: function(file, callback) {
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "uploadPhoto", [file, callback], true);
            }
            else {
                //TODO
                callback({error: {message: "Not implemented"}});
            }
        },

        /**
        * Shows a native UI component that can be used to pick friends.
        * @memberof Cocoon.Social.Facebook
        * @function showFriendPicker         
        * @param callback Handler function. The response contains the boolen 'donePressed' value and an array of selected users in the 'selection' property.
        */
        showFriendPicker: function(callback) {
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "showFriendPicker", [callback], true);
            }
            else {
                //TODO
                callback({error: {message: "Not implemented"}});
            }
        }

    };

    extension.FacebookEvent = function(nativeAvailable) {
        this.nativeAvailable = nativeAvailable;
        return this;
    }

    extension.FacebookEvent.prototype = {

        /**
        * Global Events to which you can subscribe:
        * auth.login - fired when the auth status changes from unknown to connected.
        * auth.authResponseChange - fired when the authResponse changes.
        * auth.statusChange - fired when the status changes.
        * @memberof Cocoon.Social.Facebook
        * @function subscribe          
        * @param name Name of the event.
        * @param callback The handler function.
        */
        subscribe: function(name, callback){
            if (this.nativeAvailable)
            {
                var eventKey = name + 'listeners';
                this[eventKey] = this[eventKey] || [];
                this[eventKey].push(callback);
            }
            else if (!navigator.isCocoonJS)
            {
                FB.Event.subscribe(name,callback);
            }
        },

        /**
        * Removes handlers on events so it no longer invokes your callback when the event fires.
        * @memberof Cocoon.Social.Facebook
        * @function unsubscribe             
        * @param name Name of the event.
        * @param callback The handler function.
        */
        unsubscribe: function(name, callback) {
            if (this.nativeAvailable)
            {
                var eventKey = name + 'listeners';
                var array = this[eventKey];
                if (array) {
                    var index = array.indexOf(callback);
                    if (index !== -1) {
                        array.splice(index,1);
                    }
                }
            }
            else if (!navigator.isCocoonJS)
            {
                FB.Event.unsubscribe(name,callback);
            }
        },

        notify: function(name, param) {
            var eventKey = name + 'listeners';
            var array = this[eventKey];
            if (array) {
                for (var i = 0; i< array.length; ++i) {
                    array[i](param);
                }
            }

        }
    };

    extension.Facebook = new extension.FacebookExtension();

    function fromCocoonFBStatusToFBAPIState(state) {
        if (state === 0) {
            return "connected";
        }
        else if (state === 1) {
            return "not_authorized";
        }
        else {
            return "unknown";
        }
    }

    function fromCocoonFBSessionToFBAPISession(response, error) {

        var authResponse = null;
        if (response.state === 0) {
            authResponse = {
                accessToken: response.accessToken,
                expirationDate: response.expirationDate,
                userID: response.user ? response.userID : null,
                permissions: response.permissions,
                user: response.user
            }
        }

        return {
            status: fromCocoonFBStatusToFBAPIState(response.state),
            authResponse: authResponse,
            error: error
        }

    }

    extension.SocialGamingServiceFacebook = function (fbExtension) {
        Cocoon.Social.SocialGamingServiceFacebook.superclass.constructor.call(this);
        this.fb = fbExtension;
        var me = this;
        this.fb.Event.subscribe("auth.authResponseChange", function(session) {
            me.onLoginStatusChanged.notifyEventListeners(session.status == "connected", session.error);
        });
        return this;
    }

    extension.SocialGamingServiceFacebook.prototype =  {

        currentPermissions: null,

        isLoggedIn: function() {
            return this.fb._currentSession && this.fb._currentSession.status === "connected";
        },
        login : function(callback) {
            var me = this;
            this.fb.login(function(response){
                if (callback)
                    callback(me.isLoggedIn(), response.error);
            });
        },
        logout: function(callback) {
            this.fb.logout(function(response){
                if (callback)
                    callback(response.error);
            });
        },
        getLoggedInUser : function() {
            var authResponse = this.fb._currentSession ? this.fb._currentSession.authResponse : null;
            if (authResponse && authResponse.user) {
                return fromFBUserToCocoonUser(authResponse.user);
            }
            else if (authResponse && authResponse.userID) {
                return new Cocoon.Social.Facebook.User(authResponse.userID, "Loading...");
            }
            return null;
        },
        hasPublishPermissions: function(callback) {
            this.fb.getPermissions(function(perms, error){
               callback(perms.publish_actions, error);
            });
        },
        requestPublishPermissions: function(callback) {
            var me = this;
            this.fb.requestAdditionalPermissions("publish", "publish_actions", function(response){
                if (response.error)
                    callback(false, error);
                else {
                    me.hasPublishPermissions(function(granted, error){
                        callback(granted,error);
                    });
                }
            });
        },
        requestUser: function(calback, userId) {
            var apiCall = (userId || "me");
            this.fb.api(apiCall, function(response){  
                var user = response.error ? null : fromFBUserToCocoonUser(response);
                calback(user, response.error);
            });
        },
        requestUserImage: function(callback, userID, imageSize) {
            if (!userID && this.isLoggedIn()) {
                userID = this.fb._currentSession.authResponse.userID;
            }
            var fbPictureSize = "small";
            if (imageSize === Cocoon.Social.ImageSize.THUMB) {
                  fbPictureSize = "square"
            }
            else if (imageSize === Cocoon.Social.ImageSize.MEDIUM) {
                fbPictureSize = "normal";
            }
            else if (imageSize === Cocoon.Social.ImageSize.LARGE) {
                fbPictureSize = "large";
            }
            var url = "https://graph.facebook.com/" + userID + "/picture?type=" + fbPictureSize;
            callback(url);
        },
        requestFriends: function(callback, userId) {
            var apiCall = (userId || "me") + "/friends";
            this.fb.api(apiCall, function(response){
                var friends = [];
                if (!response.error) {
                    for (var i=0; i<response.data.length; i++)
                    {
                        friends.push(fromFBUserToCocoonUser(response.data[i]));
                    }
                }
                callback(friends, response.error);
            });
        },

        //internal utility function
        preparePublishAction: function(callback) {
            if (!this.currentPermissions) {
                var me = this;
                this.fb.getPermissions(function(perms){
                    me.currentPermissions = perms;
                    if (perms)
                        me.preparePublishAction(callback);
                });
            }
            else if (this.currentPermissions.publish_actions) {
                callback(true);
            }
            else{
                this.currentPermissions = null;
                this.fb.requestAdditionalPermissions("publish", "publish_actions", function(response) {
                     callback(response.error ? false : true);
                });
            }

        },
        publishMessage: function(message, callback) {
            this.preparePublishAction(function(granted) {
                if (granted) {
                    var params = fromCocoonMessageToFBMessage(message);
                    var apiCall = "me/feed";
                    this.fb.api(apiCall, params, function(response) {
                        if (callback)
                            callback(response.error);
                    });
                }
                else {
                    if (callback)
                        callback({message: "No publish_actions permission granted"});
                }
            });
        },

        publishMessageWithDialog: function(message, callback) {
            this.fb.showShareDialog(fromCocoonMessageToFBMessage(message), function(response){
                 if (callback) {
                     callback(response.error);
                 }
            });
        },

        requestScore: function(callback, params) {
            var apiCall = ((params && params.userID) ? params.userID : "me") + "/scores";
            this.fb.api(apiCall, function(response) {
                if (response.error) {
                    callback(null, response.error)
                }
                else if (response.data && response.data.length > 0) {
                    var data = fromFBScoreToCocoonScore(response.data[0]);
                    callback(data, null);
                }
                else {
                    //No score has been submitted yet for the user
                    callback(null,null);
                }

            });
        },

        submitScore: function(score, callback, params) {
            var me = this;
            this.preparePublishAction(function(granted) {
                if (granted) {
                    me.requestScore(function(currentScore, error) {
                        if (error) {
                            //can't get the user top score. Don't send the new one because it might be worse than the top score
                            if (callback)
                                callback(error);
                           return;
                        }
                        var topScore = currentScore ? currentScore.score : 0;
                        if (score <= topScore) {
                            //don't submit the new score because a better score is already submitted
                            if (callback)
                                callback(null);
                            return;
                        }
                        var apiCall = "/" + ((params && params.userID) ? params.userID : "me") + "/scores";
                        me.fb.api(apiCall, 'POST', {score:score}, function (response) {
                             if (callback)
                                callback(response.error);
                        });
                    }, params)
                }
                else {
                    if (callback)
                        callback({message: "No publish_actions permission granted"});
                }

            })
        },

        showLeaderboard : function(callback, params) {
            if (!this._leaderboardsTemplate)
                throw "Please, provide a html template for leaderboards with the setTemplates method";
            var dialog = new Cocoon.Widget.WebDialog();
            var callbackSent = false;
            dialog.show(this._leaderboardsTemplate, function(error) {
                dialog.closed = true;
                if (!callbackSent && callback)
                    callback(error);
            });
            var me = this;
            this.fb.api(me.fb._appId + "/scores", function(response) {
                if (dialog.closed)
                    return;
                if (response.error) {
                    if (callback) {
                        callbackSent = true;
                        callback(response.error);
                        dialog.close();
                    }
                    return;
                }
                var scores = [];
                if (response.data && response.data.length) {
                    for (var i = 0; i< response.data.length; ++i) {
                        var score = fromFBScoreToCocoonScore(response.data[i]);
                        score.position = i;
                        score.imageURL = "https://graph.facebook.com/" + score.userID + "/picture";
                        score.me = score.userID === me.fb._currentSession.authResponse.userID;
                        scores.push(score);
                    }
                }
                var js = "addScores(" + JSON.stringify(scores) + ")";
                dialog.eval(js);
            });
        },

        //internal utility function
        prepareAchievements: function(reload, callback) {

            if (!this._cachedAchievements || reload) {
                var me = this;
                this.fb.api(this.fb._appId + '/achievements', function(response) {
                    if (!response.error) {
                        var achievements = [];
                        if (response.data) {
                            for (var i = 0; i < response.data.length; i++) {
                                achievements.push(fromFBAchievementToCocoonAchievement(response.data[i]))
                            }
                        }
                        me.setCachedAchievements(achievements);
                        callback(achievements, null);
                    }
                    else {
                        callback([], response.error);
                    }
                });
            }
            else {
                callback(this._cachedAchievements, null);
            }
        },

        requestAllAchievements : function(callback) {
            this.prepareAchievements(true, callback);
        },

        requestAchievements : function(callback, userID) {
            var me = this;
            this.prepareAchievements(false, function(allAchievements, error){

                if (error) {
                    callback([], error);
                    return;
                }
                var apiCall = (userID || "me") + "/achievements";
                me.fb.api(apiCall, function(response) {
                    if (!response.error) {
                        var achievements = [];
                        if (response.data) {
                            for (var i = 0; i < response.data.length; i++) {
                                var ach = me.findAchievement((response.data[i].achievement || response.data[i].data.achievement).id);
                                if (ach)
                                    achievements.push(ach);
                            }
                        }
                        callback(achievements, null);
                    }
                    else {
                        callback([], response.error);
                    }
                });

            });
        },
        submitAchievement: function(achievementID, callback) {
            if (achievementID === null || typeof achievementID === 'undefined')
                throw "No achievementID specified";
            var achID = this.translateAchievementID(achievementID);
            var me = this;
            this.preparePublishAction(function(granted) {
                if (granted) {
                    me.fb.api("me/achievements", "POST", {achievement:achID}, function (response) {
                        if (callback) {
                            callback(response.error);
                        }
                    });
                }
                else {
                    if (callback)
                        callback({message: "No publish_actions permission granted"});
                }

            });
        },
        resetAchievements : function(callback) {
            var me = this;
            this.preparePublishAction(function(granted) {
                if (granted) {
                    me.requestAchievements(function(achievements, error){
                        if (error) {
                            if (callback)
                                callback(error);
                            return;
                        }
                        var someError = null;
                        var remaining = achievements.length;
                        for (var i = 0; i < achievements.length; ++i) {
                            me.fb.api("me/achievements", "DELETE", {achievement:achievements[i].fbAchievementData.url}, function (response) {
                                if (response.error) {
                                   someError = response.error;
                                }
                                remaining--;
                                if (remaining == 0 && callback) {
                                    callback(someError);
                                }
                            });
                        }

                    });
                }
                else {
                    if (callback)
                        callback({message: "No publish_actions permission granted"});
                }

            });
        },
        showAchievements : function(callback) {
            if (!this._achievementsTemplate)
                throw "Please, provide a html template for achievements with the setTemplates method";
            var dialog = new Cocoon.Widget.WebDialog();
            var callbackSent = false;
            dialog.show(this._achievementsTemplate, function(error) {
                dialog.closed = true;
                if (!callbackSent && callback)
                    callback(error);
            });
            var me = this;
            this.requestAchievements(function(achievements, error){
                if (dialog.closed)
                    return;
                if (error) {
                    callbackSent = true;
                    if (callback)
                        callback(error);
                    return;
                }

                var achs = [];
                if (me._cachedAchievements) {
                    for (var i = 0; i < me._cachedAchievements.length; ++i) {
                        var ach = me._cachedAchievements[i];
                        achs.push(ach);
                        if (achievements && achievements.length) {
                            for (var j = 0; j< achievements.length; ++j) {
                                if (achievements[j].achievementID === ach.achievementID) {
                                    ach.achieved = true;
                                    break;
                                }
                            }
                        }
                    }
                }
                var js = "addAchievements(" + JSON.stringify(achs) + ");";
                dialog.eval(js);
            });
        }
    }

    Cocoon.extend(extension.SocialGamingServiceFacebook, extension.SocialGamingService);

    function fromFBUserToCocoonUser(facebookUser) {
        return new Cocoon.Social.User(facebookUser.id, facebookUser.username ? facebookUser.username : (facebookUser.first_name + " " + facebookUser.last_name ));
    }

    function fromCocoonMessageToFBMessage(message) {
        return {
            link: message.linkURL,
            description: message.message,
            name: message.linkText,
            caption: message.linkCaption,
            picture: message.mediaURL
        }
    }

    function fromFBScoreToCocoonScore(fbResponse, requestScoreParams) {
        var result = new Cocoon.Social.Score(fbResponse.user.id, fbResponse.score, fbResponse.user.name);
        if (requestScoreParams) {
            result.leaderboardID = requestScoreParams.leaderboardID;
        }
        result.imageURL = 'https://graph.facebook.com/' + fbResponse.user.id + '/picture';
        return result;
    }

    function fromFBAchievementToCocoonAchievement(fbResponse) {
        var result = new Cocoon.Social.Achievement (
            fbResponse.id,
            fbResponse.title,
            fbResponse.description,
            fbResponse.image[0].url,
            fbResponse.data.points
        );
        result.fbAchievementData = fbResponse;
        return result;
    }

    // Do not insert this code in CocoonJS || Node
    if (!navigator.isCocoonJS && !(typeof module !== 'undefined' && module.exports) ) {
        // Load the Facebook SDK
        var parent = document.getElementsByTagName('script')[0];
        var script = document.createElement('script');
        //script.async = true;
        var prot = location.protocol ? location.protocol : "http:"
        script.src = prot + "//connect.facebook.net/en_US/all.js";
        parent.parentNode.insertBefore(script, parent);
    }
    
    return extension;
});;/**
 * 
 *
 * <div class="alert alert-success">
 *   Here you will find a demo about this namespace: <a href="https://github.com/ludei/cocoonjs-demos/tree/master/Multiplayer">Multiplayer demo</a>.
 *</div>
 * 
 * <div class="alert alert-warning">
 *    <strong>Warning!</strong> This JavaScript extension requires some configuration parameters on the <a href="https://ludei.zendesk.com/hc/en-us">cloud compiler</a>!
 * </div>
 * @namespace Cocoon.Multiplayer
 */
Cocoon.define("Cocoon.Multiplayer" , function(extension){

	extension.MultiplayerService = function(nativeExtensionName, extensionName)
	{
		this.nativeExtensionName = nativeExtensionName;
		this.extensionName = extensionName;
	    this.nativeAvailable = (!!window.ext) && (!!window.ext[this.nativeExtensionName]);

        var me = this;

        this.onInvitationReceived = new Cocoon.EventHandler(this.nativeExtensionName, this.extensionName, "onInvitationReceived");

        this.onInvitationLoaded = new Cocoon.EventHandler(this.nativeExtensionName, this.extensionName, "onInvitationLoaded", function(sourceListener, args){
            var matchID = args[0];
            var error = args[1];
            if (matchID && !error) {
                me.currentMatch =  new Cocoon.Multiplayer.Match(me.nativeExtensionName, me.extensionName, matchID);
                sourceListener(me.currentMatch, null)
            }
            else {
                sourceListener(null, error);
            }
        });

        var signal = new Cocoon.Signal.createSignal();

        signal.register("invitation", {
            received : this.onInvitationReceived,
            loaded : this.onInvitationLoaded,
        });

        this.on = signal.expose();

        return this;
	};


	extension.MultiplayerService.prototype = {

        currentMatch: null,

        /**
         * Presents a system View for the matchmaking and creates a new Match.
         * @function findMatch
         * @memberOf Cocoon.Multiplayer
         * @private
         * @param {Cocoon.Multiplayer.MatchRequest} matchRequest The parameters for the match.
         * @param {Function} callback The callback function. It receives the following parameters: 
         * - {@link Cocoon.Multiplayer.Match}. 
         * - Error. 
         */
        findMatch : function(matchRequest, callback)  {
            var me = this;
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "findMatch", [matchRequest, function(matchID,error) {
                    if (matchID && !error) {
                        me.currentMatch =  new Cocoon.Multiplayer.Match(me.nativeExtensionName, me.extensionName, matchID);
                        callback(me.currentMatch, null)
                    }
                    else {
                        callback(null, error);
                    }
                }], true);
            }
        },

        /**
         * Sends an automatch request to join the authenticated user to a match. It doesn't present a system view while waiting to other players.
         * @function findAutoMatch
         * @memberOf Cocoon.Multiplayer   
         * @private      
         * @param  {Cocoon.Multiplayer.MatchRequest} matchRequest The parameters for the match.
         * @param {Function} callback The callback function. It receives the following parameters: 
         * - {@link Cocoon.Multiplayer.Match}. 
         * - Error.
         */
        findAutoMatch : function(matchRequest, callback) {
            var me = this;
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "findAutoMatch", [matchRequest, function(matchID, error){
                    if (matchID && !error) {
                        me.currentMatch =  new Cocoon.Multiplayer.Match(me.nativeExtensionName, me.extensionName, matchID);
                        callback(me.currentMatch, null)
                    }
                    else {
                        callback(null, error);
                    }
                }], true);
            }
        },

        /**
         * Cancels the ongoing automatch request.
         * @function cancelAutoMatch
         * @memberOf Cocoon.Multiplayer    
         * @private        
         */
        cancelAutoMatch : function() {
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "cancelAutoMatch", [], true);
            }
        },

        /**
         * Automatically adds players to an ongoing match owned by the user.
         * @function addPlayersToMatch
         * @memberOf Cocoon.Multiplayer 
         * @private         
         * @param {Cocoon.Multiplayer.MatchRequest} matchRequest The parameters for the match.
         * @param {Cocoon.Multiplayer.Match} matchRequest The match where new players will be added.
         * @param {Function} callback The callback function. Response parameters: error.
         */
        addPlayersToMatch : function(matchRequest, match, callback) {
            if (this.nativeAvailable) {
                Cocoon.callNative(this.nativeExtensionName, "addPlayersToMatch", [matchRequest, match.matchID, callback], true);
            }
        },

        /**
         * Get the current match reference.
         * @function getMatch
         * @memberOf Cocoon.Multiplayer      
         * @private    
         * @return {Cocoon.Multiplayer.Match} The current match reference.
         */
        getMatch : function() {
            return this.currentMatch;
        }
	};

	/**
	* This type provides a transmission network between a group of users.
	* The match might be returned before connections have been established between players. At this stage, all the players are in the process of connecting to each other.
	* Always check the getExpectedPlayerCount value before starting a match. When its value reaches zero, all expected players are connected, and your game can begin the match.
	* Do not forget to call the start method of the match when your game is ready to process received messages via onMatchDataReceived listener.
    * @constructor Match
    * @memberOf Cocoon.Multiplayer
	* @param {string} nativeExtensionName The name of the native ext object extension property name.
	* @param {string} extensionName The name of the CocoonJS object extension property name.
	* @param {number} matchID The match ID user for native service bridge.
	*/
	extension.Match = function(nativeExtensionName, extensionName, matchID)
	{
		if (typeof nativeExtensionName !== 'string') throw "The given native extension name '" + nativeExtensionName + "' is not a string.";
		if (typeof extensionName !== 'string') throw "The given extension name '" + nativeExtensionName + "' is not a string.";

		this.nativeExtensionName = nativeExtensionName;
		this.extensionName = extensionName;
	    this.nativeAvailable = Cocoon.nativeAvailable && typeof window.ext[nativeExtensionName] !== 'undefined';
	    this.matchID = matchID;
	    var me = this;

	    this.onMatchDataReceived = new Cocoon.EventHandler(this.nativeExtensionName, this.extensionName, "onMatchDataReceived", function(sourceListener, args) {
	    		if (me.matchID === args[0]) {
	    			sourceListener(me, args[1], args[2]);
	    		}
	    	});

	    this.onMatchStateChanged = new Cocoon.EventHandler(this.nativeExtensionName, this.extensionName, "onMatchStateChanged", function(sourceListener, args) {
	    		if (me.matchID === args[0]) {
	    			sourceListener(me, args[1], args[2]);
	    		}
	    	});

	    this.onMatchConnectionWithPlayerFailed = new Cocoon.EventHandler(this.nativeExtensionName, this.extensionName, "onMatchConnectionWithPlayerFailed", function(sourceListener, args) {
	    		if (me.matchID === args[0]) {
	    			sourceListener(me, args[1], args[2]);
	    		}
	    	});

	    this.onMatchFailed = new Cocoon.EventHandler(this.nativeExtensionName, this.extensionName, "onMatchFailed", function(sourceListener, args) {
	    		if (me.matchID === args[0]) {
	    			sourceListener(me, args[1]);
	    		}
	    	});



        var signal = new Cocoon.Signal.createSignal();

        /**
        * Allows to listen to events about the restoring process.
        * - The callback 'dataReceived' 
        * - The callback 'stateChanged' 
        * - The callback 'connectionWithPlayerFailed' allows listening to events called when a netowrk connection with a player fails
        * - The callback 'failed' allows listening to events called when the match fails.
        * @event On restore products callbacks
        * @memberof Cocoon.Multiplayer.Match
        * @example
        * Cocoon.Store.on("restore",{
        *  dataReceived: function(match, data, playerId){ ... },
        *  stateChanged: function(match, playerId, connectionState){ ... },
        *  connectionWithPlayerFailed: function(match, playerId, errorMsg){ ... }
        *  failed: function(match, errorMsg){ ... }
        * });
        */
        signal.register("match", {
            dataReceived : this.onMatchDataReceived,
            stateChanged : this.onMatchStateChanged,
            connectionWithPlayerFailed : this.onMatchConnectionWithPlayerFailed,
            failed : this.onMatchFailed
        });

        this.on = signal.expose();
	};

	extension.Match.prototype = {

		/**
		* Starts processing received messages. The user must call this method when the game is ready to process messages. Messages received before being prepared are stored and processed later.
        * @function start
        * @memberOf Cocoon.Multiplayer.Match
		*/
		start : function() {
			if (this.nativeAvailable) {
				Cocoon.callNative(this.nativeExtensionName, "startMatch", [this.matchID], true);
			}
		},

		/**
		* Transmits data to all players connected to the match. The match queues the data and transmits it when the network becomes available.
        * @function sendDataToAllPlayers
        * @memberOf Cocoon.Multiplayer.Match		
		* @param {string} data The data to transmit.
		* @param {Cocoon.Multiplayer.SendDataMode} [sendMode] The optional {@link Cocoon.Multiplayer.SendDataMode} value. The default value is RELIABLE.
		* @return {boolean} TRUE if the data was successfully queued for transmission; FALSE if the match was unable to queue the data.
		*/
		sendDataToAllPlayers : function(data, sendMode) {
			if (this.nativeAvailable) {
				return Cocoon.callNative(this.nativeExtensionName, "sendDataToAllPlayers", [this.matchID, data, sendMode]);
			}
		},

		/**
		* Transmits data to a list of connected players. The match queues the data and transmits it when the network becomes available.
        * @function sendData
        * @memberOf Cocoon.Multiplayer.Match		
		* @param {string} data The data to transmit
		* @param {array} playerIDs An array containing the identifier strings for the list of players who should receive the data.
		* @param {Cocoon.Multiplayer.SendDataMode} [sendMode] The optional {@link Cocoon.Multiplayer.SendDataMode} value. The default value is RELIABLE.
		* @return {boolean} TRUE if the data was successfully queued for transmission; FALSE if the match was unable to queue the data.
		*/
		sendData : function(data, playerIDs,  sendMode) {
			if (this.nativeAvailable) {
				return Cocoon.callNative(this.nativeExtensionName, "sendData", [this.matchID, data, playerIDs, sendMode]);
			}
		},
	
		/**
		* Disconnects the local player from the match and releases the match. Calling disconnect notifies other players that you have left the match.
        * @function disconnect
        * @memberOf Cocoon.Multiplayer.Match			
		*/
		disconnect : function() {
			if (this.nativeAvailable) {
				return Cocoon.callNative(this.nativeExtensionName, "disconnect", [this.matchID], true);
			}
		},
		
		/**
		* Requests additional information of the current players in the match.
        * @function requestPlayersInfo
        * @memberOf Cocoon.Multiplayer.Match        
        * @param {Function} callback The callback function. Response params: players array and error
		*/
		requestPlayersInfo : function(callback) {
			if (this.nativeAvailable){
				return Cocoon.callNative(this.nativeExtensionName, "requestPlayersInfo", [this.matchID, callback], true);
			}
		},

		/**
		* Returns the remaining players count who have not yet connected to the match.
		* @function getExpectedPlayerCount
        * @memberOf Cocoon.Multiplayer.Match 		
		* @return {number} The remaining number of players who have not yet connected to the match.
		*/
		getExpectedPlayerCount : function() {
			if (this.nativeAvailable) {
				return Cocoon.callNative(this.nativeExtensionName, "getExpectedPlayerCount", [this.matchID]);
			}
		},

		/**
		* Returns an array with all the player identifiers taking part in the match.
		* @function getPlayerIDs
        * @memberOf Cocoon.Multiplayer.Match 				
		* @return {array} The player identifiers for the players in the match.
		*/
		getPlayerIDs : function() {
			if (this.nativeAvailable){
				return Cocoon.callNative(this.nativeExtensionName, "getPlayerIDs", [this.matchID]);
			}
		},

        /**
        * Gets the local playerID taking part in the match.
		* @function getLocalPlayerID
        * @memberOf Cocoon.Multiplayer.Match 	         
        * @return {string} the playerID attached to the match manager.
        */
        getLocalPlayerID : function() {
            if (this.nativeAvailable) {
                return Cocoon.callNative(this.nativeExtensionName, "getLocalPlayerID", [this.matchID]);
            }
            return "";
        },

	};

    /**
    * This object represents the modes to send data.
    * @memberof Cocoon.Multiplayer 
    * @name Cocoon.Multiplayer.SendDataMode
    * @property {object} Cocoon.Multiplayer.SendDataMode - The object itself
    * @property {string} Cocoon.Multiplayer.SendDataMode.RELIABLE The data is sent continuously until it is successfully received by the intended recipients or the connection times out.
    * @property {string} Cocoon.Multiplayer.SendDataMode.UNRELIABLE The data is sent once and is not sent again if a transmission error occurs.
    */  
	extension.SendDataMode =  {

	    RELIABLE : 0,

	    UNRELIABLE : 1
	};

    /**
    * This object represents the connection state of a player.
    * @memberof Cocoon.Multiplayer 
    * @name Cocoon.Multiplayer.ConnectionState
    * @property {object} Cocoon.Multiplayer.ConnectionState - The object itself
    * @property {string} Cocoon.Multiplayer.ConnectionState.UNKNOWN The connection is in unknown state.
    * @property {string} Cocoon.Multiplayer.ConnectionState.CONNECTED The connection is in connected state.
    * @property {string} Cocoon.Multiplayer.ConnectionState.DISCONNECTED The connection is in disconnected state.    
    */ 
	extension.ConnectionState = {

	    UNKNOWN : 0,

	    CONNECTED : 1,

	    DISCONNECTED : 2
	};

    /**
    * The object that represents the information of a player inside a multiplayer match.
    * @memberof Cocoon.Multiplayer 
    * @name Cocoon.Multiplayer.PlayerInfo
    * @property {object} Cocoon.Multiplayer.PlayerInfo - The object itself
    * @property {string} Cocoon.Multiplayer.PlayerInfo.userID The id of the user.
    * @property {string} Cocoon.Multiplayer.PlayerInfo.userName The name of the user.
    */
	extension.PlayerInfo = function(userID, userName) {

		this.userID = userID;

		this.userName = userName;
	};

    /**
    * This object is used to specify the parameters for a new multiplayer match.
    * @memberof Cocoon.Multiplayer 
    * @name Cocoon.Multiplayer.MatchRequest
    * @property {object} Cocoon.Multiplayer.MatchRequest - The object itself
    * @property {number} Cocoon.Multiplayer.MatchRequest.minPlayers The minimum number of players that may join the match.
    * @property {number} Cocoon.Multiplayer.MatchRequest.maxPlayers The maximum number of players that may join the match.
	* @property {array} [Cocoon.Multiplayer.MatchRequest.playersToInvite] Optional list of player identifers for players to invite to the match.
    * @property {number} [Cocoon.Multiplayer.MatchRequest.playerGroup] Optional number identifying a subset of players allowed to join the match.
    * @property {number} [Cocoon.Multiplayer.MatchRequest.playerAttributes] Optional mask that specifies the role that the local player would like to play in the game.
    */
	extension.MatchRequest = function(minPlayers, maxPlayers, playersToInvite, playerGroup, playerAttributes) {

		this.minPlayers = minPlayers;

		this.maxPlayers = maxPlayers;

		this.playersToInvite = playersToInvite;

		this.playerGroup = playerGroup;

		this.playerAttributes = playerAttributes;

		return this;
	};
	
	return extension;
});;/**
 * 
 * <div class="alert alert-warning">
 *    <strong>Warning!</strong> This JavaScript extension requires some configuration parameters on the <a href="https://ludei.zendesk.com/hc/en-us">cloud compiler</a>!
 * </div>
 * @private
 * @namespace Cocoon.Multiplayer.LoopbackService
 */
Cocoon.define("Cocoon.Multiplayer" , function(extension){

    var loopbackServices = [];
    var indexCounter = 0;
    var matchServices = [];
    var matchCounter = 0;

    extension.LoopbackService = function() {

        Cocoon.Multiplayer.LoopbackService.superclass.constructor.call(this, "dummy","dummy");
        loopbackServices.push(this);
        this.playerID = "" + indexCounter;
        indexCounter++;

    }

    extension.LoopbackService.prototype =  {

        findMatch : function(request, callback)  {

            this.findMatchCallback = callback;

            //checks if the service is already added to the match list
            var exists = false;
            for (var i = 0; i< matchServices.length; ++i) {
                if (matchServices[i] === this) {
                    exists = true; break;
                }
            }
            if (!exists)
                matchServices.push(this);

            //Create the match is all required players are ready
            //TODO: check more conditions (playerGroup, playerAttributes) to complete a match
            if (matchServices.length >= request.minPlayers) {
                var playerIDs = [];
                //create playerIDs array
                for (var i = 0; i< matchServices.length; ++i) {
                    playerIDs.push(matchServices[i].getPlayerID());
                }

                //notify the found match to each manager
                for (var i = 0; i< matchServices.length; ++i) {
                    var match = new LoopbackMatch(matchServices[i]);
                    match.playerIDs = playerIDs.slice();
                    matchServices[i].currentMatch = match;
                    matchServices[i].findMatchCallback(match, null);
                }
                //clear pending list
                matchServices = [];
            }


        },
        findAutoMatch : function(matchRequest, callback) {
            this.findMatch(matchRequest,callback);
        },
        cancelAutoMatch : function() {

        },

        addPlayersToMatch : function(matchRequest, match, callback) {
            callback({message:"Not implemmented"});
        },
        getPlayerID : function() {
            return this.playerID;
        },

        getMatch : function() {
            return this.currentMatch;
        }
    }

    Cocoon.extend(extension.LoopbackService, extension.MultiplayerService);

    var LoopbackMatch = function(service) {
        matchCounter++;
        LoopbackMatch.superclass.constructor.call(this, "","",matchCounter);
        this.started = false;
        this.disconnected = false;
        this.pendingData = [];
        this.service = service;
    }

    LoopbackMatch.prototype = {

        start : function() {
            var me = this;
            setTimeout(function() {
                me.started = true;
                for (var i = 0; i < me.pendingData.length; ++i) {
                    me.onMatchDataReceived.notifyEventListeners(me.matchID,me.pendingData[i].data, me.pendingData[i].player);
                }

            },0);

        },
        sendDataToAllPlayers : function(data, sendMode) {
            this.sendData(data, this.playerIDs, sendMode);
        },

        sendData : function(data, playerIDs,  sendMode) {
            var me = this;
            setTimeout(function() {
                for (var i = 0; i< loopbackServices.length; ++i) {
                    var destService = null;
                    for (var j = 0; j < playerIDs.length; ++j) {
                        if (playerIDs[j] === loopbackServices[i].getPlayerID()) {
                            destService = loopbackServices[i];
                        }
                    }
                    if (destService) {
                        destService.getMatch().notifyDataReceived(data,me.service.getPlayerID());
                    }
                }
            },0);
        },

        disconnect : function() {
            this.disconnected = true;
            for (var i = 0; i < this.playerIDs.length; ++i) {
                var p = this.playerIDs[i];
                for (var j = 0; j < loopbackServices.length; ++j) {
                    if (loopbackServices[j].getPlayerID() === p) {
                        var match = loopbackServices[i].getMatch();
                        if (!match.disconnected) {
                            match.onMatchStateChanged.notifyEventListeners(match, this.service.getPlayerID(), Cocoon.Multiplayer.ConnectionState.DISCONNECTED);
                        }
                    }
                }
            }
        },

        requestPlayersInfo : function(callback) {
            var me = this;
            setTimeout(function() {
               var playersInfo = [];
                for (var i = 0; i < me.playerIDs.length; ++i) {
                    playersInfo[i] = {userID: me.playerIDs[i], userName: "Player" + me.playerIDs[i]};
                };
                callback(playersInfo);
            },1);
        },

        getExpectedPlayerCount : function() {
            return 0;
        },
        getPlayerIDs : function() {
            return this.playerIDs;
        },
        getLocalPlayerID: function() {
            return this.service.playerID;
        },
        notifyDataReceived: function(data, fromPlayer) {
            if (!this.started) {
                this.pendingData.push({data:data, player:fromPlayer});
            }
            else {
                this.onMatchDataReceived.notifyEventListeners(this.matchID,data,fromPlayer);
            }
        }

    };

    Cocoon.extend(LoopbackMatch, Cocoon.Multiplayer.Match);

    return extension;
});;/**
 *
 * <div class="alert alert-success">
 *   Here you will find a demo about this namespace: <a href="https://github.com/ludei/cocoonjs-demos/tree/master/Multiplayer">Multiplayer demo</a>.
 *</div>
 * 
 * <div class="alert alert-warning">
 *    <strong>Warning!</strong> This JavaScript extension requires some configuration parameters on the <a href="https://ludei.zendesk.com/hc/en-us">cloud compiler</a>!
 * </div>
 * @namespace Cocoon.Multiplayer.GooglePlayGames
 * @example 
 * var GooglePlayGames = Cocoon.Multiplayer.GooglePlayGames;
 * var SocialGooglePlay = GooglePlayGames.getSocialInterface();
 * var MultiplayerGooglePlay = GooglePlayGames.getMultiplayerInterface();
 * 
 * SocialGooglePlay.login(function(loggedIn, error) {
 * 	if(loggedIn){
 * 		var request = new Cocoon.Multiplayer.MatchRequest(2,2);
 * 		var handleMatch = function(match, error){
 * 		
 * 		}
 * 		...
 * 		MultiplayerGooglePlay.findMatch(request, handleMatch);
 * 		...
 * 	}
 * });
 */
Cocoon.define("Cocoon.Multiplayer" , function(extension){

    extension.GooglePlayGames = new Cocoon.Multiplayer.MultiplayerService("IDTK_SRV_MULTIPLAYER_GPG", "Multiplayer.GooglePlayGames");
	
    /**
     * Presents a system View for the matchmaking and creates a new Match.
     * @function findMatch
     * @memberOf Cocoon.Multiplayer.GooglePlayGames
     * @param {Cocoon.Multiplayer.MatchRequest} matchRequest The parameters for the match.
     * @param {Function} callback The callback function. It receives the following parameters: 
     * - {@link Cocoon.Multiplayer.Match}. 
     * - Error. 
     */

     /**
     * Sends an automatch request to join the authenticated user to a match. It doesn't present a system view while waiting to other players.
     * @function findAutoMatch
     * @memberOf Cocoon.Multiplayer.GooglePlayGames 
     * @param  {Cocoon.Multiplayer.MatchRequest} matchRequest The parameters for the match.
     * @param {Function} callback The callback function. It receives the following parameters: 
     * - {@link Cocoon.Multiplayer.Match}. 
     * - Error.
     */

     /**
	 * Cancels the ongoing automatch request.
	 * @function cancelAutoMatch
	 * @memberOf Cocoon.Multiplayer.GooglePlayGames
	 */

	 /**
     * Automatically adds players to an ongoing match owned by the user.
     * @function addPlayersToMatch
     * @memberOf Cocoon.Multiplayer.GooglePlayGames
     * @param {Cocoon.Multiplayer.MatchRequest} matchRequest The parameters for the match.
     * @param {Cocoon.Multiplayer.Match} matchRequest The match where new players will be added.
     * @param {Function} callback The callback function. Response parameters: error.
     */

     /**
     * Get the current match reference.
     * @function getMatch
     * @memberOf Cocoon.Multiplayer.GooglePlayGames
     * @return {Cocoon.Multiplayer.Match} The current match reference.
     */

	return extension;
});
;/**
 *
 * <div class="alert alert-success">
 *   Here you will find a demo about this namespace: <a href="https://github.com/ludei/cocoonjs-demos/tree/master/Multiplayer">Multiplayer demo</a>.
 *</div>
 *  
 * <div class="alert alert-warning">
 *    <strong>Warning!</strong> This JavaScript extension requires some configuration parameters on the <a href="https://ludei.zendesk.com/hc/en-us">cloud compiler</a>!
 * </div>
 * @namespace Cocoon.Multiplayer.GameCenter
 * @example
 * var GameCenter = CocoonJS.Social.GameCenter;
 * var SocialGameCenter = gc.getSocialInterface();
 * var MultiplayerGameCenter = gc.getMultiplayerInterface();
 * 
 * SocialGameCenter.login(function(loggedIn, error) {
 * 	if(loggedIn){
 * 		var request = new Cocoon.Multiplayer.MatchRequest(2,2);
 * 		var handleMatch = function(match, error){
 * 		
 * 		}
 * 		...
 * 		MultiplayerGameCenter.findMatch(request, handleMatch);
 * 		...
 * 	}
 * });
 */
Cocoon.define("Cocoon.Multiplayer" , function(extension){

	extension.GameCenter = new Cocoon.Multiplayer.MultiplayerService("IDTK_SRV_MULTIPLAYER_GAMECENTER", "Multiplayer.GameCenter");
	/**
     * Presents a system View for the matchmaking and creates a new Match.
     * @function findMatch
     * @memberOf Cocoon.Multiplayer.GameCenter
     * @param {Cocoon.Multiplayer.MatchRequest} matchRequest The parameters for the match.
     * @param {Function} callback The callback function. It receives the following parameters: 
     * - {@link Cocoon.Multiplayer.Match}. 
     * - Error. 
     */

     /**
     * Sends an automatch request to join the authenticated user to a match. It doesn't present a system view while waiting to other players.
     * @function findAutoMatch
     * @memberOf Cocoon.Multiplayer.GameCenter 
     * @param  {Cocoon.Multiplayer.MatchRequest} matchRequest The parameters for the match.
     * @param {Function} callback The callback function. It receives the following parameters: 
     * - {@link Cocoon.Multiplayer.Match}. 
     * - Error.
     */

     /**
	 * Cancels the ongoing automatch request.
	 * @function cancelAutoMatch
	 * @memberOf Cocoon.Multiplayer.GameCenter
	 */

	 /**
     * Automatically adds players to an ongoing match owned by the user.
     * @function addPlayersToMatch
     * @memberOf Cocoon.Multiplayer.GameCenter
     * @param {Cocoon.Multiplayer.MatchRequest} matchRequest The parameters for the match.
     * @param {Cocoon.Multiplayer.Match} matchRequest The match where new players will be added.
     * @param {Function} callback The callback function. Response parameters: error.
     */

     /**
     * Get the current match reference.
     * @function getMatch
     * @memberOf Cocoon.Multiplayer.GameCenter
     * @return {Cocoon.Multiplayer.Match} The current match reference.
     */
	return extension;
});