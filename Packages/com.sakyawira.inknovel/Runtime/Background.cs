using System.Collections.Generic;
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
        public List<Sprite> Day;
        public List<Sprite> Twilight;
        public List<Sprite> Evening;

        public List<Sprite> GetSprite(Time time)
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
