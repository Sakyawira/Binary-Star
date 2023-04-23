using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace Sakyawira.InkNovel
{
    public enum TagID
    {
        CHARACTER_NAME = 0,
        EMOTION = 1
    }

    public class TagTransposer : MonoBehaviour
    {
        [SerializeField]
        private UnityEvent<string> _characterNameEvent;
        [SerializeField]
        private UnityEvent _noCharacterNameEvent;
        [SerializeField]
        private UnityEvent<List<Sprite>> _playerCharacterSpriteEvent;
        [SerializeField]
        private UnityEvent<List<Sprite>> _nonPlayerCharacterSpriteEvent;
        [SerializeField]
        private CharacterDatabase _characterDatabase;
        [SerializeField]
        private UnityEvent _npcDialogueEndEvent;
        [SerializeField]
        private UnityEvent _playerDialogueEndEvent;
        [SerializeField]
        private bool _transposeName = false;

        private const string _playerName = "Aneska";

        public UnityEvent TransposeTags(List<string> tags)
        {
            var dict = new Dictionary<TagID, string>();
            for (int i = 0; i < tags.Count; i++)
            {
                dict[(TagID)i] = tags[i];
            }
            if (dict.ContainsKey(TagID.CHARACTER_NAME))
            {
                TransposeName(dict[TagID.CHARACTER_NAME]);
                if (dict.ContainsKey(TagID.EMOTION))
                {
                    TransposeEmotion(dict[TagID.CHARACTER_NAME], Enum.Parse<Emotion>(dict[TagID.EMOTION]));
                }
                else
                {
                    TransposeEmotion(dict[TagID.CHARACTER_NAME], Emotion.NEUTRAL);
                }
                if (dict[TagID.CHARACTER_NAME] == _playerName)
                {
                    return _playerDialogueEndEvent;
                }
                return _npcDialogueEndEvent;
            }
            else
            {
                _noCharacterNameEvent.Invoke();
                return null;
            }
        }

        private void TransposeName(string tag)
        {
            if (_transposeName)
            {
                _characterNameEvent.Invoke(tag);
            }
        }

        private void TransposeEmotion(string name, Emotion emotion)
        {
            var sprite = _characterDatabase.GetSprite(name, emotion);
            if (name == _playerName)
            {
                _playerCharacterSpriteEvent.Invoke(sprite);
                return;
            }
            _nonPlayerCharacterSpriteEvent.Invoke(sprite);
        }
    }
}
