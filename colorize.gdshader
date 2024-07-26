shader_type canvas_item;

uniform vec4 card_color : source_color;

void fragment(){
	vec4 color = texture(TEXTURE,UV);
	
	if (color == vec4(1,1,1,1)){
		COLOR = vec4(1,1,1,1);
	}
	//else 
	//	COLOR = color;	
		
}