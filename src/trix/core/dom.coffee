html = document.documentElement
match = html.matchesSelector ? html.webkitMatchesSelector ? html.msMatchesSelector ? html.mozMatchesSelector

Trix.DOM = dom =
  handleEvent: (eventName, {onElement, matchingSelector, withCallback, inPhase, preventDefault} = {}) ->
    element = onElement ? html
    selector = matchingSelector
    callback = withCallback
    useCapture = inPhase is "capturing"

    handler = (event) ->
      target = dom.findClosestElementFromNode(event.target, matchingSelector: selector)
      withCallback?.call(target, event, target) if target?
      event.preventDefault() if preventDefault

    handler.destroy = ->
      element.removeEventListener(eventName, handler, useCapture)

    element.addEventListener(eventName, handler, useCapture)
    handler

  triggerEvent: (eventName, {onElement, bubbles, cancelable} = {}) ->
    element = onElement ? html
    bubbles = bubbles isnt false
    cancelable = cancelable isnt false

    event = document.createEvent("Events")
    event.initEvent(eventName, bubbles, cancelable)
    element.dispatchEvent(event)
    event

  elementMatchesSelector: (element, selector) ->
    if element?.nodeType is 1
      match.call(element, selector)

  findClosestElementFromNode: (node, {matchingSelector} = {}) ->
    return unless node
    node = node.parentNode until node.nodeType is Node.ELEMENT_NODE

    if matchingSelector?
      while node
        return node if dom.elementMatchesSelector(node, matchingSelector)
        node = node.parentNode
    else
      node

  findNodeForContainerAtOffset: (container, offset) ->
    return unless container
    if container.nodeType is Node.TEXT_NODE
      container
    else if offset is 0
      container.firstChild ? container
    else
      container.childNodes.item(offset - 1)

  findElementForContainerAtOffset: (container, offset) ->
    node = dom.findNodeForContainerAtOffset(container, offset)
    dom.findClosestElementFromNode(node)

  measureElement: (element) ->
    width:  element.offsetWidth
    height: element.offsetHeight

  walkTree: (tree, {onlyNodesOfType, usingFilter, expandEntityReferences} = {}) ->
    whatToShow = switch onlyNodesOfType
      when "element" then NodeFilter.SHOW_ELEMENT
      when "text" then NodeFilter.SHOW_TEXT
      else NodeFilter.SHOW_ALL

    document.createTreeWalker(tree, whatToShow, usingFilter, expandEntityReferences is true)
