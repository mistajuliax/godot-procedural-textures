tool
extends "res://addons/material_maker/node_base.gd"

const BLEND_TYPES = [
	{ name="Normal", shortname="normal" },
	{ name="Dissolve", shortname="dissolve" },
	{ name="Multiply", shortname="multiply" },
	{ name="Screen", shortname="screen" },
	{ name="Overlay", shortname="overlay" },
	{ name="Hard Light", shortname="hard_light" },
	{ name="Soft Light", shortname="soft_light" },
	{ name="Burn", shortname="burn" },
	{ name="Dodge", shortname="dodge" },
	{ name="Lighten", shortname="lighten" },
	{ name="Darken", shortname="darken" },
	{ name="Difference", shortname="difference" }
]

func _ready():
	$blend_type.clear()
	for i in range(BLEND_TYPES.size()):
		$blend_type.add_item(BLEND_TYPES[i].name, i)
	initialize_properties([ $blend_type, $HBoxContainer/amount ])

func _get_shader_code(uv, slot = 0):
	var rv = { defs="", code="" }
	var src0 = get_source(0)
	var src1 = get_source(1)
	var src2 = get_source(2)
	if src0 == null or src1 == null:
		return rv
	var src0_code = src0.get_shader_code(uv)
	var src1_code = src1.get_shader_code(uv)
	var src2_code = { defs="", code="" }
	var amount_str = "%.9f" % parameters.amount
	if src2 != null:
		src2_code = src2.get_shader_code(uv)
		amount_str = src2_code.f
	if generated_variants.empty():
		rv.defs = src0_code.defs+src1_code.defs+src2_code.defs
	var variant_index = generated_variants.find(uv)
	if variant_index == -1:
		variant_index = generated_variants.size()
		generated_variants.append(uv)
		rv.code = src0_code.code+src1_code.code+src2_code.code
		rv.code += "vec4 %s_%d_rgba = vec4(blend_%s(%s, %s, %s, %s * %s.a), min(1.0, %s.a + %s * %s.a));\n" % [ name, variant_index, BLEND_TYPES[parameters.blend_type].shortname, uv, src0_code.rgb, src1_code.rgb, amount_str, src0_code.rgba, src1_code.rgba, amount_str, src0_code.rgba ]
	rv.rgba = "%s_%d_rgba" % [ name, variant_index ]
	return rv

func _get_state_variables():
	return [ "amount" ]
