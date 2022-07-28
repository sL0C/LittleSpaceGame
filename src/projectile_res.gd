extends Resource
class_name ProjectileRes

export(String) var name = ""
export(Texture) var texture = null
export(float) var speed = 1.0

enum ProjectileTypes {Laser, Rocket}
export(ProjectileTypes) var type
