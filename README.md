
# It is a lightweight 2D game engine in progress(written on Object Pascal and compilled in Lazarus). 
# Uses software rendering. 
# Of the features, I can note the super high performance of splines and sprites(work is still being done on it). 
# In the future, a powerful editor for sprites, splines and other game objects will be available.
# Executable file is included, so run-n-fun 😉. 

Screenshots:
   1. Editor Mode
![EditorPrev0](https://github.com/OlegMathProg/AvalokiTech/assets/51221856/d9a51c4b-277d-41d7-85c6-728667953307)


   2. Game Mode
![EditorPrev1](https://github.com/OlegMathProg/AvalokiTech/assets/51221856/01d4f48e-d0fb-41ea-9204-60a327d87401)



Nearest TODO:
  - Optimization:
    1. get rid of double, triple or quadruple addressing (priority: low; complexity: easy);
    2. ...;
  - UI:
    1. implementation of object tags(priority: high; complexity: middling);
    2. ...;
  - Sprites:
    1. implementation of rotation and scaling of CSR-images(Compressed Sparse Row), possibly with bilinear filtering (priority: medium; complexity: very hard);
    2. ...;
  - Splines:
    1. static contour anti-aliasing for sparse sprites in CSR format (priority: low; complexity: hard);
    2. implementation of drawing for CSR-lines of any width greater than 3 (priority: low; complexity: very hard);
    3. Bezier splines (priority: high; complexity: middling).
