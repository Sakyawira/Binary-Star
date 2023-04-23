using System.Collections.Generic;
using UnityEngine;

namespace Sakyawira.InkNovel
{
    public enum Emotion
    {
        NEUTRAL,
        ANGRY,
        HAPPY,
        JOY,
        SAD
    }

    [CreateAssetMenu(menuName = "Character/Character", fileName = "New Character")]
    public class Character : ScriptableObject
    {
        public string Name;
        public List<Sprite> Neutral;
        public List<Sprite> Angry;
        public List<Sprite> Happy;
        public List<Sprite> Joy;
        public List<Sprite> Sad;

        public List<Sprite> GetSprite(Emotion emotion)
        {
            switch (emotion)
            {
                case Emotion.NEUTRAL:
                    return Neutral;

                case Emotion.ANGRY:
                    return Angry;

                case Emotion.HAPPY:
                    return Happy;

                case Emotion.JOY:
                    return Joy;

                case Emotion.SAD:
                    return Sad;

                default:
                    return Neutral;
            }
        }
    }
}
