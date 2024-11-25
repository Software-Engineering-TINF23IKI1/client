# Framework/Tech comparison
|Criteria|Flutter|React Native|Godot|
|---------|----------|------------------|---------|
|UI & Animation | Smooth, highly customizable |Native-like, some limitations | specialized for games |
|Performance| Direct compilation, very smooth | 	JavaScript bridge, good | excellent for 2D/3D games | 
|Learning Curve| Requires learning Dart |	JavaScript, easier for JS devs | moderate, requires learning GDScript or the usage of C#/C++
|Cross-Platform Consistency| High consistency|	Minor variations across platforms | High
|Ecosystem|	Growing, fewer plugins | Large, mature |works out of the box
|Real-Time Multiplayer | Smooth UI refreshes |Effective, slight bridge delay | built-in websocket, optimized

## _other notes_ ## 
### web support/export ## 
- Flutter offers a more consistent cross-platform experience, while React Native may require workarounds to achieve uniformity, especially for web and desktop support
- Godot exports to HTML5/WebAssembly, which works well, but performance on web can sometimes lag compared to native desktop or mobile builds, especially in heavier games.


# Key comparison use cases 
| Use Case | Best Option |
| ----------|-----------|
| **Smooth Animations & Real-Time UI** | Flutter > Godot > React Native |
| **Advanced Game Features** | Godot
| **Simple UIs & Quick Setup** | Flutter > React Native
**Real-Time Multiplayer** |	Godot = Flutter > React Native |
**Web-Focused Experience** | Flutter > Godot > React Native
**Mobile App-Like Game** | Flutter > React Native
Desktop Targeting |Godot > Flutter


### Conclusion ###
- React Native is not an option in our case, due to the clunky web/desktop building options
- Flutter is the best choice if consistency across platforms is the priority and for clean mobile app like games
- Godot is the best choice if we choose a game first approach and UI is not a priority, but rather complex graphic solutions (custom sprites, ...)



