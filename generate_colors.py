import os
import json

colors = {
    "SageGreen": {"any": "#8CAF9B", "dark": "#719A82"},
    "MutedWood": {"any": "#BFA588", "dark": "#9F866A"},
    "DeepShadow": {"any": "#2A2D2A", "dark": "#161816"},
    "SoftWhite": {"any": "#F8F9F7", "dark": "#E6E8E5"},
    "SubtleGray": {"any": "#8E928F", "dark": "#A5A9A6"}
}

assets_dir = "/Users/abhishekthakur/Dev_2/Kaizen/Kaizen/Kaizen/Assets.xcassets"

def hex_to_rgb(hex_str):
    hex_str = hex_str.lstrip('#')
    return tuple(int(hex_str[i:i+2], 16)/255.0 for i in (0, 2, 4))

for name, variants in colors.items():
    color_dir = os.path.join(assets_dir, f"{name}.colorset")
    os.makedirs(color_dir, exist_ok=True)
    
    def make_color(hex_str):
        r, g, b = hex_to_rgb(hex_str)
        return {
            "color-space": "srgb",
            "components": {
                "red": f"{r:.3f}",
                "green": f"{g:.3f}",
                "blue": f"{b:.3f}",
                "alpha": "1.000"
            }
        }
        
    contents = {
        "info": {"version": 1, "author": "xcode"},
        "colors": [
            {
                "idiom": "universal",
                "color": make_color(variants['any'])
            },
            {
                "idiom": "universal",
                "appearances": [{"appearance": "luminosity", "value": "dark"}],
                "color": make_color(variants['dark'])
            }
        ]
    }
    
    with open(os.path.join(color_dir, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)

print("Colors generated successfully.")
