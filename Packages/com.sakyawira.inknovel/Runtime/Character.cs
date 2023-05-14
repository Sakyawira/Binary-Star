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
        public Sprite SingleNeutral;
        public List<Sprite> Neutral;
        public Sprite SingleAngry;
        public List<Sprite> Angry;
        public Sprite SingleHappy;
        public List<Sprite> Happy;
        public Sprite SingleJoy;
        public List<Sprite> Joy;
        public Sprite SingleSad;
        public List<Sprite> Sad;

        public List<Sprite> GetSprites(Emotion emotion)
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

        public Sprite GetSprite(Emotion emotion)
        {
            switch (emotion)
            {
                case Emotion.NEUTRAL:
                    return SingleNeutral;

                case Emotion.ANGRY:
                    return SingleAngry;

                case Emotion.HAPPY:
                    return SingleHappy;

                case Emotion.JOY:
                    return SingleJoy;

                case Emotion.SAD:
                    return SingleSad;

                default:
                    return SingleNeutral;
            }
        }
    }
}
