shader_type canvas_item;

// Variável que controlamos pelo GDScript (0.0 a 1.0)
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    // Pega a cor original do pixel do sprite
    vec4 color = texture(TEXTURE, UV);
    
    // Mistura a cor original com Branco (vec3(1,1,1)) 
    // O flash_modifier decide o quanto de branco será aplicado
    color.rgb = mix(color.rgb, vec3(1, 1, 1), flash_modifier);
    
    // Aplica a cor final mantendo a transparência original
    COLOR = color;
}