using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Sakyawira.InkNovel
{
    [CreateAssetMenu(menuName = "Character/Character Database", fileName = "New Character Database")]
    public class CharacterDatabase : ScriptableObject
    {
        [SerializeField]
        private List<Character> _characterList;

        public List<Sprite> GetSprites(string characterName, Emotion emotion)
        {
            return _characterList.Where(x => x.Name == characterName).First().GetSprites(emotion);
        }
        public Sprite GetSprite(string characterName, Emotion emotion)
        {
            return _characterList.Where(x => x.Name == characterName).First().GetSprite(emotion);
        }
    }
}
