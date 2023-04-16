using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Sakyawira.UI
{
    public interface ISpriteManipulator
    {
        public void GreyOut();
        public void TurnOffCharacterImage();
        public void ChangeSprite(Sprite sprite);
    }
}
