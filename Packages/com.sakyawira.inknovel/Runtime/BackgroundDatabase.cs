using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Sakyawira.InkNovel
{
    [CreateAssetMenu(menuName = "Background/Background Database", fileName = "New Background Database")]
    public class BackgroundDatabase : ScriptableObject
    {
        [SerializeField]
        private List<Background> _backgroundList;

        public List<Sprite> GetSprite(string place, Time time)
        {
            return _backgroundList.Where(x => x.Name == place).First().GetSprite(time);
        }
    }
}
