# Reinforcement learning for legged robots

This is a crash course on applying reinforcement learning to train policies that balance real legged robots. We first review the necessary basics: partially-observable Markov decision processes, value functions, the goal of reinforcement learning. We then focus on policy optimization: REINFORCE, policy gradient and proximal policy optimization (PPO). After some practical advice on training with PPO, we finally focus on techniques to train real-robot policies from simulation data: domain randomization, simulation augmentation and reward shaping.

- [Slides](https://scaron.info/slides/reinforcement-learning-legged-robots.pdf)

## Usage

The slides can be built with [pixi](https://pixi.sh):

- Build slides: `pixi run make`
- Open the slides: `pixi run open`
- Rebuild slides on source updates: `pixi run watch`

Run `pixi task list` to list all available tasks. The first build will bootstrap a TeX Live build environment, with a minimal distribution installed by default to `~/.local/share/texlive-projects/`.

## History

This lecture has been given in the following classes:

- *MAREVA option* at [Mines de Paris](https://www.minesparis.psl.eu/) (2023-2026)
- *Robotics* at [Master MVA](https://www.master-mva.com/cours/robotics/) (2023-2025)
- *Planification de mouvement en robotique et en animation graphique* at [ENS](https://www.ens.psl.eu/) (2023-2025)
