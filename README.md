# Git Heroes

An leaderboard for your Github organisation.

Hosted at [githeroes.io](https://app.githeroes.io)

## Goals and Features

For engineers:

- Highlight reviewing bottlenecks: immediately see which pull requests don't get
  reviewed... or have turned into review hell.
- Get regular updates on your Github rhythm: a simple, daily email summary of
  your activity and what needs reviewing.
- Gamify the Github experience: a weekly leaderboard of who did the most
  commenting, who was the most helpful, etc.

For engineering managers:

- Encourage code reviews within teams; and
- Promote code reviews across organisation teams: per-team and per-organisation
  chord graphs of reviewing dynamics. Spot collaboration issues.
- Visualize your team's progress: stable activity metrics, across the team and
  normalised per person.
- Know your best contributors: leaderboard of top active contributors.


## Running locally

Requirements (macOS):

- Ruby 2.3. We recommend installing with
  [`rbenv`](https://github.com/rbenv/rbenv) and the
  [`ruby-build`](https://github.com/rbenv/ruby-build) plugin.
- Local resolution support, so that `http://githeroes.dev` works. We recommend
  [`puma-dev`](https://github.com/puma/puma-dev).

Installing:

```
git clone https://github.com/mezis/git-heroes-app.git
cd git-heroes-app
bundle install
echo 3000 > ~/.puma-dev/githeroes
```

Running:

```
rails s -p 3000 -b 0.0.0.0
```

Then visit [https://githeroes.dev/](https://githeroes.dev/).


## License

Git Heroes is provided under the terms of the [GNU AGPL
v3](https://www.gnu.org/licenses/agpl-3.0.html).

In particular: everyone's welcome to use the code, contribute to it, and run it.
You may not, however, deploy a modified version of the code without contributing
all changes back to this repository (preferably as pull requests).


## Contributing

All [pull requests](https://github.com/mezis/git-heroes-app/pulls) are welcome!

If you'd like to work on Git Heroes but don't know on what, ake a look at the
current [projects](https://github.com/mezis/git-heroes-app/projects) and
[issues](https://github.com/mezis/git-heroes-app/issues).



