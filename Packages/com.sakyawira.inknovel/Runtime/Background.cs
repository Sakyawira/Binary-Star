using UnityEngine;

namespace Sakyawira.InkNovel
{
    public enum Time
    {
        DAY,
        TWILIGHT,
        EVENING
    }

    [CreateAssetMenu(menuName = "Background/Background", fileName = "New Background")]
    public class Background : ScriptableObject
    {
        public string Name;
        public Sprite Day;
        public Sprite Twilight;
        public Sprite Evening;

        public Sprite GetSprite(Time time)
        {
            switch (time)
            {
                case Time.DAY:
                    return Day;

                case Time.TWILIGHT:
                    return Twilight;

                case Time.EVENING:
                    return Evening;

                default:
                    return Day;
            }
        }
    }
}
