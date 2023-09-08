/*
Porting the project was performed by RedErr404 <red.err404@gmail.com
*/

#if TOOLS
using System;
using System.Collections.Generic;
using System.Diagnostics;
using Godot;

[Tool]
public partial class CharacterControllerPlugin : EditorPlugin
{
    private static readonly Dictionary<string, object> CharacterControllerForward = new()
    {
        { "name", "move_forward" },
        { "events", new List<object> { new Dictionary<string, object> { { "physical_keycode", (int)Godot.Key.W } } } }
    };

    private static readonly Dictionary<string, object> CharacterControllerBackward = new()
    {
        { "name", "move_backward" },
        { "events", new List<object> { new Dictionary<string, object> { { "physical_keycode", (int)Godot.Key.S } } } }
    };

    private static readonly Dictionary<string, object> CharacterControllerRight = new()
    {
        { "name", "move_right" },
        { "events", new List<object> { new Dictionary<string, object> { { "physical_keycode", (int)Godot.Key.D } } } }
    };

    private static readonly Dictionary<string, object> CharacterControllerLeft = new()
    {
        { "name", "move_left" },
        { "events", new List<object> { new Dictionary<string, object> { { "physical_keycode", (int)Godot.Key.A } } } }
    };

    private static readonly Dictionary<string, object> CharacterControllerSprint = new()
    {
        { "name", "move_sprint" },
        { "events", new List<object> { new Dictionary<string, object> { { "physical_keycode", (int)Godot.Key.Shift } } } }
    };

    private static readonly Dictionary<string, object> CharacterControllerJump = new()
    {
        { "name", "move_jump" },
        { "events", new List<object> { new Dictionary<string, object> { { "physical_keycode", (int)Godot.Key.Space } } } }
    };

    private static readonly Dictionary<string, object> CharacterControllerCrouch = new()
    {
        { "name", "move_crouch" },
        { "events", new List<object> { new Dictionary<string, object> { { "physical_keycode", (int)Godot.Key.Ctrl } } } }
    };

    private static readonly Dictionary<string, object> CharacterControllerFlyMode = new()
    {
        { "name", "move_fly_mode" },
        { "events", new List<object> { new Dictionary<string, object> { { "physical_keycode", (int)Godot.Key.F } } } }
    };

    private static readonly List<Dictionary<string, object>> Actions = new()
    {
        CharacterControllerForward,
        CharacterControllerBackward,
        CharacterControllerRight,
        CharacterControllerLeft,
        CharacterControllerSprint,
        CharacterControllerJump,
        CharacterControllerCrouch,
        CharacterControllerFlyMode
    };

    public override void _EnterTree()
    {
        // Register input events
        foreach (var actionProps in Actions)
        {
            string settingName = "input/" + actionProps["name"];

            if (!ProjectSettings.HasSetting(settingName))
            {
                List<InputEvent> events = new();

                var actionPropsEvents = (List<object>)actionProps["events"];

                foreach (var eventData in actionPropsEvents)
                {
                    InputEventKey e = new();
                    var eventDataDict = (Dictionary<string, object>)eventData;
                    foreach (var propName in eventDataDict.Keys)
                    {
                        e.Set(propName, Variant.From(eventDataDict[propName]));
                    }
                    events.Add(e);
                }

                float deadzone = actionProps.ContainsKey("deadzone") ? (float)actionProps["deadzone"] : 0.5f;
                ProjectSettings.SetSetting(settingName,  Variant.From(new Dictionary<string, object> { { "deadzone", deadzone }, { "events", events} }));
            }
        }

        Error result = ProjectSettings.Save();
        Debug.Assert(result == Error.Ok, "Failed to save project settings");
    }

    public override void _ExitTree()
    {
        // Clean-up of the plugin goes here
    }
}
#endif