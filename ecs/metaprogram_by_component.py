# This python script uses metaprogramming to automatically write boilerplate for the ecs

import os
dir_path = os.path.dirname(os.path.abspath(__file__))

parse_file_names = [f for f in os.listdir(dir_path) if f.endswith("_components.odin")]

components = []

for file_path in parse_file_names:
    with open(os.path.join(dir_path, file_path), "r") as scraping:
        for line in scraping:
            if line.strip().endswith("Component :: struct {"):
                prefix = line.strip()[:-len("Component :: struct {")]
                components.append(prefix)

def lower_with_underscore(str):
    result = [str[0].lower()]
    for char in str[1:]:
        if char.isupper():
            result.append('_')
        result.append(char.lower())
    return ''.join(result)

def ecs_state_struct_plate():
    ret = ""
    i = 0
    for component in components:
        if i > 0:
            ret += "\t"
        i += 1
        ret += f"{lower_with_underscore(component)}_cc: ComponentCollection({component}Component),\n"
    return ret[:-1]

def comp_id_enum():
    ret = ""
    i = 0
    for component in components:
        if i > 0:
            ret += "\t"
        i += 1
        ret += f"{component}_CE,\n"
    return ret[:-1]

def destroy_ecs_component_data_plate():
    ret = ""
    i = 0
    for component in components:
        if i > 0:
            ret += "\t"
        i += 1
        ret += f"destroy_{lower_with_underscore(component)}_component_data,\n"
    return ret[:-1]

def destroy_ecs_state_plate():
    ret = ""
    i = 0
    for component in components:
        if i > 0:
            ret += "\t"
        i += 1
        ret += f"destroy_component_collection(ecs_state^, &ecs_state.{lower_with_underscore(component)}_cc)\n"
    return ret[:-1]

def stock_ecs_state_ccs_plate():
    ret = ""
    i = 0
    for component in components:
        if i > 0:
            ret += "\t"
        i += 1
        ret += f"state.{lower_with_underscore(component)}_cc = create_component_collection({component}Component)\n"
    return ret[:-1]

def get_component_id_lookup():
    ret = ""
    i = 0
    for component in components:
        if i > 0:
            ret += "\t"
        i += 1
        ret += f'''case {component}Component:
        return .{component}_CE\n'''
    return ret[:-1]

def destroy_entity_switch_plate():
    ret = ""
    i = 0
    for component in components:
        if i > 0:
            ret += "\t\t\t"
        i += 1
        ret += f'''case .{component}_CE:
                destroy_ecs_component(ecs_state, entity, &ecs_state.{lower_with_underscore(component)}_cc)\n'''
    return ret[:-1]


final_code = f'''package ecs
import sdl "vendor:sdl3"
import g4n "../g4n"

// Entities - Components - Systems
ECSState :: struct {{
    active_entities: EntityID,

    {ecs_state_struct_plate()}

    entity_bitsets: [MAX_ENTITIES]bit_set[ComponentID],
}}

ComponentID :: enum {{
    {comp_id_enum()}
}}

destroy_ecs_component_data :: proc{{
    {destroy_ecs_component_data_plate()}
}}

destroy_ecs_component_collections :: proc(ecs_state: ^ECSState) {{
    {destroy_ecs_state_plate()}
}}

stock_ecs_state_component_collections :: proc(state: ^ECSState) {{
    {stock_ecs_state_ccs_plate()}
}}

get_component_id :: proc(T: typeid) -> ComponentID {{
	switch T {{
    {get_component_id_lookup()}
	}}

    // need to replace this with error or default case
	return .Position_CE
}}

destroy_entity :: proc(ecs_state: ^ECSState, entity: EntityID) {{
    for e in ComponentID {{
        if e in ecs_state.entity_bitsets[entity] {{
            switch e {{
            {destroy_entity_switch_plate()}
            }}
        }}
    }}
}}'''

with open(os.path.join(dir_path, "by_component_code.odin"), "w") as output:
    output.write(final_code)