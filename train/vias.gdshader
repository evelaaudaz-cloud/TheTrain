shader_type spatial;

uniform sampler2D textura_vias; // Tu imagen de vías/pasto
uniform float velocidad = 200.0;  // Esto lo controlaremos desde GDScript

void fragment() {
    // Tomamos las coordenadas de la textura (UV)
    vec2 uv_movida = UV;
    
    // El truco: sumamos el tiempo multiplicado por la velocidad al eje Y del UV
    // Esto hace que la imagen "deslice" sobre el plano sin que el plano se mueva
    uv_movida.y -= TIME * velocidad;
    
    // Aplicamos la textura movida al color del suelo
    vec4 color = texture(textura_vias, uv_movida);
    ALBEDO = color.rgb;
}