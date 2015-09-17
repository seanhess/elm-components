Elm.Native.Drag = {};
Elm.Native.Drag.make = function(elm)
{
  elm.Native = elm.Native || {};
  elm.Native.Drag = elm.Native.Drag || {};
  if (elm.Native.Drag.values)
  {
    return elm.Native.Drag.values;
  }

	var Json = Elm.Native.Json.make(elm);
	var Signal = Elm.Native.Signal.make(elm);

	function property(key, value)
	{
		return {
			key: key,
			value: value
		};
	}

  // so, now what?
	function onMouseDownInside(decoder, createMessage)
	{
		function eventHandler(event)
		{
      var element = this
			var value = A2(Json.runDecoderValue, decoder, event);
			if (value.ctor === 'Ok')
			{
        function onMouseUp(event) {
          document.documentElement.removeEventListener("mouseup", onMouseUp, true)
          document.documentElement.removeEventListener("mousemove", onMouseMove, false)

          // stop it from triggering twice if inside the element
          event.stopPropagation()

          var ev = new MouseEvent("mouseup", event)
          element.dispatchEvent(ev)
        }

        function onMouseMove(event) {

          // stop it from triggering twice if inside the element
          event.stopPropagation()

          // copy the event init properties into options, but set bubbles to false
          var options = eventInitProperties.reduce(function(opts, field) {
            opts[field] = event[field] 
            return opts
          }, {})
          options.bubbles = false

          var ev = new MouseEvent("mousemove", options)
          element.dispatchEvent(ev)
        }

        // now, attach a document listener. We need to use capture
        // so we can intercept it before it hits the element, to avoid triggering 2x
        document.documentElement.addEventListener("mouseup", onMouseUp, true)
        document.documentElement.addEventListener("mousemove", onMouseMove, false)

				Signal.sendMessage(createMessage(value._0));
			}
		}
		return property('onmousedown', eventHandler);
	}

  return Elm.Native.Drag.values = {
    onMouseDownInside: F2(onMouseDownInside)
  };
};

// https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent/MouseEvent
var eventInitProperties = ["screenX", "screenY", "clientX", "clientY", "ctrlKey", "shiftKey", "altKey", "metaKey", "button", "buttons", "relatedTarget", "region", "detail", "view", "bubbles", "cancelable"]
//var uiEventProperties = ["detail", "view"]
// 
