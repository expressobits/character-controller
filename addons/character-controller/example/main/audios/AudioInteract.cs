using System;
using Godot;
using Godot.Collections;

[Tool]
public partial class AudioInteract : Resource
{
    [Export] public AudioStream JumpAudio;
    [Export] public AudioStream LandedAudio;
    [Export] public Array<AudioStream> StepAudios = new Array<AudioStream>();

    public AudioStream RandomStep()
    {
        if (StepAudios.Count == 0) return null;

        Random random = new Random();
        return StepAudios[random.Next(0, StepAudios.Count)];
    }
}
