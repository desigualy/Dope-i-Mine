"""
Dope-i-Mine Avatar Engine V4 - Blender starter asset generator.

Run inside Blender:
  blender --background --python tools/avatar_assets/blender/create_base_avatar_starter.py

Output:
  assets/avatar_glb/base_avatar.glb

Purpose:
  Creates a real, valid starter GLB with:
  - named materials
  - named anchor empties
  - simple humanoid mesh stand-ins
  - basic shape keys / morph targets
  - export path expected by the Flutter plugin pipeline

This is NOT final Apple/Meta-quality avatar art.
This is a production pipeline starter so the app has a real GLB to render,
validate, upload, and map against.
"""

from __future__ import annotations

import math
from pathlib import Path

import bpy


PROJECT_ROOT = Path(__file__).resolve().parents[3]
OUTPUT_PATH = PROJECT_ROOT / "assets" / "avatar_glb" / "base_avatar.glb"


MATERIALS = {
    "skin_material": (0.72, 0.50, 0.38, 1.0),
    "hair_material": (0.08, 0.06, 0.045, 1.0),
    "eye_material": (0.12, 0.08, 0.04, 1.0),
    "top_material": (0.18, 0.32, 0.52, 1.0),
    "bottom_material": (0.10, 0.12, 0.16, 1.0),
    "outerwear_material": (0.20, 0.20, 0.22, 1.0),
    "shoe_material": (0.05, 0.05, 0.05, 1.0),
    "accessory_material": (0.75, 0.75, 0.78, 1.0),
}

ANCHORS = [
    ("head_anchor", (0, 0, 1.75)),
    ("hair_anchor", (0, -0.02, 1.88)),
    ("headwear_anchor", (0, 0, 1.95)),
    ("glasses_anchor", (0, -0.12, 1.76)),
    ("left_ear_anchor", (-0.16, 0, 1.75)),
    ("right_ear_anchor", (0.16, 0, 1.75)),
    ("back_anchor", (0, 0.17, 1.30)),
    ("left_hand_anchor", (-0.56, 0, 0.95)),
    ("right_hand_anchor", (0.56, 0, 0.95)),
    ("accessibility_anchor", (0.68, 0, 0.92)),
    ("wheelchair_anchor", (0, 0.28, 0.55)),
]


def clear_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()


def make_material(name: str, rgba: tuple[float, float, float, float]) -> bpy.types.Material:
    material = bpy.data.materials.new(name)
    material.use_nodes = True
    bsdf = material.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = rgba
        bsdf.inputs["Roughness"].default_value = 0.65
    return material


def add_uv_sphere(name: str, location, scale, material: bpy.types.Material) -> bpy.types.Object:
    bpy.ops.mesh.primitive_uv_sphere_add(segments=48, ring_count=24, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    obj.data.materials.append(material)
    return obj


def add_cube(name: str, location, scale, material: bpy.types.Material) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cube_add(location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    obj.data.materials.append(material)
    return obj


def add_cylinder(name: str, location, radius, depth, material: bpy.types.Material) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=radius, depth=depth, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(material)
    return obj


def add_anchor(name: str, location) -> bpy.types.Object:
    bpy.ops.object.empty_add(type="PLAIN_AXES", location=location)
    obj = bpy.context.object
    obj.name = name
    obj.empty_display_size = 0.055
    return obj


def add_basic_shape_keys(obj: bpy.types.Object) -> None:
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    obj.shape_key_add(name="Basis")

    key_specs = {
        "jaw_width": (1.08, 1.0, 1.0),
        "cheek_fullness": (1.04, 1.02, 1.02),
        "chin_length": (1.0, 1.0, 1.08),
        "face_softness": (1.02, 1.02, 1.0),
    }

    for key_name, scale in key_specs.items():
        key = obj.shape_key_add(name=key_name)
        for vertex in key.data:
            vertex.co.x *= scale[0]
            vertex.co.y *= scale[1]
            vertex.co.z *= scale[2]

    obj.select_set(False)


def create_avatar() -> None:
    materials = {name: make_material(name, rgba) for name, rgba in MATERIALS.items()}

    add_cube("avatar_torso", (0, 0, 1.05), (0.32, 0.18, 0.46), materials["top_material"])
    add_cube("avatar_hips", (0, 0, 0.62), (0.30, 0.16, 0.20), materials["bottom_material"])
    head = add_uv_sphere("avatar_head", (0, 0, 1.67), (0.18, 0.16, 0.22), materials["skin_material"])
    add_basic_shape_keys(head)

    hair = add_uv_sphere("hair_mesh_default", (0, 0.015, 1.79), (0.19, 0.17, 0.12), materials["hair_material"])
    hair.name = "hair_mesh_default"

    add_uv_sphere("eye_left", (-0.065, -0.145, 1.70), (0.025, 0.012, 0.018), materials["eye_material"])
    add_uv_sphere("eye_right", (0.065, -0.145, 1.70), (0.025, 0.012, 0.018), materials["eye_material"])

    add_cylinder("neck", (0, 0, 1.42), 0.075, 0.18, materials["skin_material"])

    for side, x in [("left", -0.42), ("right", 0.42)]:
        upper = add_cylinder(f"{side}_upper_arm", (x, 0, 1.18), 0.045, 0.42, materials["skin_material"])
        upper.rotation_euler[1] = math.radians(90)
        lower = add_cylinder(f"{side}_lower_arm", (x * 1.16, 0, 0.95), 0.04, 0.38, materials["skin_material"])
        lower.rotation_euler[1] = math.radians(90)
        add_uv_sphere(f"{side}_hand", (x * 1.37, -0.02, 0.95), (0.045, 0.035, 0.05), materials["skin_material"])

    for side, x in [("left", -0.13), ("right", 0.13)]:
        add_cylinder(f"{side}_upper_leg", (x, 0, 0.28), 0.055, 0.55, materials["bottom_material"])
        add_cylinder(f"{side}_lower_leg", (x, 0, -0.22), 0.047, 0.48, materials["skin_material"])
        add_cube(f"{side}_shoe", (x, -0.055, -0.50), (0.075, 0.13, 0.035), materials["shoe_material"])

    glasses = add_cube("glasses_frame_default", (0, -0.16, 1.70), (0.15, 0.012, 0.025), materials["accessory_material"])
    glasses.hide_viewport = True
    glasses.hide_render = True

    for name, location in ANCHORS:
        add_anchor(name, location)

    bpy.ops.object.light_add(type="AREA", location=(0, -3, 3))
    light = bpy.context.object
    light.name = "avatar_preview_softbox"
    light.data.energy = 350
    light.data.size = 4

    bpy.ops.object.camera_add(location=(0, -3.0, 1.35), rotation=(math.radians(72), 0, 0))
    bpy.context.scene.camera = bpy.context.object


def export_glb() -> None:
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=str(OUTPUT_PATH),
        export_format="GLB",
        export_apply=True,
        export_materials="EXPORT",
        export_animations=True,
        export_skins=True,
        export_morph=True,
    )
    print(f"Exported {OUTPUT_PATH}")


def main() -> None:
    clear_scene()
    create_avatar()
    export_glb()


if __name__ == "__main__":
    main()
