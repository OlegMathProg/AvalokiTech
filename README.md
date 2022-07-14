![Logo11](https://user-images.githubusercontent.com/51221856/176084166-de159cc9-3d2e-4ac3-9639-304e62bf8704.png)

# It is a 2D game engine in progress(written on Object Pascal and compilled in Lazarus). 
# Uses software rendering. 
# Of the features, I can note the super high performance of splines and sprites(work is still being done on it). 
# In the future, a powerful editor for sprites, splines and other game objects will be available.
# Executable file(MorphoEngine.exe) is included, so run-n-fun 😉. 

Screenshots:
   1. Editor Mode
![Editor_Preview0](https://user-images.githubusercontent.com/51221856/178884113-2ac4ed86-0ffe-4db9-b326-71759a297816.png)
![Editor_Preview1](https://user-images.githubusercontent.com/51221856/177308584-ca19e9cc-2ba0-43bc-97e7-3e257b6f906b.png)
   2. Game Mode
![Editor_Preview2](https://user-images.githubusercontent.com/51221856/176085844-7cfe4ab0-61d7-4245-a4bf-adbc7cfb91fa.png)

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
