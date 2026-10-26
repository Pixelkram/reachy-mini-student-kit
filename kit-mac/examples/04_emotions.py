"""04 - Play recorded emotions or dances from the Hugging Face Hub.

Pollen Robotics publishes libraries of recorded moves as HF datasets.
The first run downloads the dataset (internet needed), later runs use the cache.

    python examples/04_emotions.py              # list moves, play 3 random emotions
    python examples/04_emotions.py --library dance --count 2
    python examples/04_emotions.py --move <name>
"""

import argparse
import random

from reachy_mini import ReachyMini
from reachy_mini.motion.recorded_move import RecordedMoves

LIBRARIES = {
    "emotions": "pollen-robotics/reachy-mini-emotions-library",
    "dance": "pollen-robotics/reachy-mini-dances-library",
}

parser = argparse.ArgumentParser()
parser.add_argument("--library", choices=LIBRARIES, default="emotions")
parser.add_argument("--move", help="name of a single move to play")
parser.add_argument("--count", type=int, default=3, help="number of random moves")
args = parser.parse_args()

moves = RecordedMoves(LIBRARIES[args.library])
names = sorted(moves.list_moves())
print(f"{len(names)} moves in '{args.library}':")
print(", ".join(names))

to_play = [args.move] if args.move else random.sample(names, min(args.count, len(names)))

with ReachyMini(media_backend="no_media") as mini:
    for name in to_play:
        move = moves.get(name)
        print(f"\nPlaying '{name}' ({move.duration:.1f} s): {move.description}")
        # sound=False because media is disabled in this script
        mini.play_move(move, initial_goto_duration=1.0, sound=False)
