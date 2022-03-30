![Logo3](https://user-images.githubusercontent.com/51221856/131055087-984f233a-a2b4-4bb8-b1bf-d8ecc2f7de60.png)

# It is a 2D game engine in progress(written on Free Pascal and compilled in Lazarus). 
# Uses software rendering. 
# Of the features, I can note the super high performance of splines and sprites(work is still being done on it). 
# In the future, a powerful editor for sprites, splines and other game objects will be available.

Screenshots:
![EditorPreview0](https://user-images.githubusercontent.com/51221856/160921947-4f552c98-457f-4f9c-a314-3e104984b6a4.png)

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
