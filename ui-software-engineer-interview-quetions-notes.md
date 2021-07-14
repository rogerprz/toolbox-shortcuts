# UI SWE interview questions

## 1. How absolute, relative, a static and fixed position will differ?

**Absolute**: 
- It will place the element exactly where a user wants to place it. In general absolute will place relative to the parent. 
If no parent is available, then it is placed relative to the page itself.

**Relative:** 
- It will place the element relative to itself (if we didn’t give any relative positioning); 
for example, if we set position relative to an element and given as top: 10px, 
then it will place the element 10px down from where the actual position of the element to be.

**Static:** 
- It will place the element according to the flow of the document. 
It uses the default position; if we want to remove any position, then we can use a static position to replace it.

**Fixed:** 
- It will place the element relative to the browser window or viewport as viewport doesn’t change when scrolling. 
So element will be fixed at that position.


## 2. What is the difference between inline, block and inline-block?
**Inline:**
- In this thing, elements will follow the flow without breaking. Margin/padding will push other elements horizontally, not vertically, and inline elements ignore height and width.

**Block:** 
- It breaks the line and doesn’t fit in the line. It usually has div, p, text, section etc.

**Inline-block:**
- It is similar to the inline element and follows the page flow. The only difference is that it will consider height and width.
