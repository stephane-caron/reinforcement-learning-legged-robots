# Reinforcement learning for legged robots

This is a crash course on applying reinforcement learning to train policies that balance real legged robots. We first review the necessary basics: partially-observable Markov decision processes, value functions, the goal of reinforcement learning. We then focus on policy optimization: REINFORCE, policy gradient and proximal policy optimization (PPO). After some practical advice on training with PPO, we finally focus on techniques to train real-robot policies from simulation data: domain randomization, simulation augmentation and reward shaping.

- [Slides](https://scaron.info/slides/reinforcement-learning-legged-robots.pdf)

## Usage

The slides can be built with [pixi](https://pixi.sh):

- Build slides: `pixi run slides-make`
- Rebuild slides on source updates: `pixi run slides-watch`
- Open the slides: `pixi run slides-open`

Run `pixi task list` to list all available tasks. The first build will bootstrap a TeX Live build environment, with a minimal distribution installed by default to `~/.local/share/texlive-projects/`.

## History

This lecture has been given in the following classes:

- *Robotics* at [MVA](https://www.master-mva.com/cours/robotics/) (Fall 2023, Fall 2024, Fall 2025)
- *Introduction to Robotics* (part 2) at Mines de Paris (Fall 2023, Fall 2024, Fall 2025)
- *Planification de mouvement en robotique et en animation graphique* at [ENS Paris](https://www.ens.psl.eu/) (Fall 2023, Fall 2024, Fall 2025)
