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
        public Sprite Neutral;
        public Sprite Angry;
        public Sprite Happy;
        public Sprite Joy;
        public Sprite Sad;

        public Sprite GetSprite(Emotion emotion)
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
