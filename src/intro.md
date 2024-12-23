# Introduction

## Goal
Automatically format, lint, and run tests on our code before publishing.

## Concepts
- Formatting
Following consistent code formatting removes the endless discussion of preference from code reviews. Tabs vs spaces, Single vs double quotes, etc. One becomes better at reading code when all code is formatted the same way.
Most languages have their own style-guide that sets the standard. It is best to adopt the existing standard and move on.
If the default style is really untennible, it is possible to set one's local editor to display code in one style and automaticaly push code formatted a different way.
This is out of the scope of this guide.
[This document](https://book.the-turing-way.org/reproducible-research/code-quality/code-quality-style.html) has more info on why formatting code matters.


- Linting
Linting


- Testing




Unfortunatly writing code off the bat this way can add mental overhead. Remembering to run formatter/linter/tests before pushing changes happens too often.
Ideally, we should be able to write our code the way we want and let the computers do the work to check our code and make fixes where they can and suggestions where unsure.
Even better, it would be nice if this process could happen automatically so we don't have to remember to trigger it.


## How we get there

### Git Hooks
Git has [built-in support](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) for running arbitrary scripts before operations such as `git commit` or `git push`.
We can write our own script to format/lint/test our code

For example, imagine running this script before each `git commit` operation

```bash
#!/usr/bin/env bash

# Non-zero exit codes stop git-commit from continuing

if ! do-format; then
  echo "Formatting failed"
  exit 1
fi 

if ! lint-my-code; then
  echo "Linter found issues"
  exit 1
fi

if ! run-test; then
  echo "Test(s) failed"
  exit 1
fi

echo "No issues found"
# git-commit to continue
```
where `do-format`, `lint-my-code`, and `run-tests` are our programs to format/lint/test.
We literally would be unable to commit code that isn't formatted, linted, and tested.

This isn't a magic bullet; we are only as good as the underlying `do-format` `lint-my-code` programs,
but this guarenttees we've at least checked *something*.

Git allows for hooking many operations, but we are going to focus on `pre-commit` hooks.


#### The double edge to this sword
Pre-commit hooks can admitely add some friction to the development process.
The pre-commit hooks will stop us from commiting incorrect code (according to our formatter/linter/tests),
which means we are *blocked* from commiting until these checks pass.

Sometimes we absolutly need to make a commit right now and, for example, don't have time to diagonse errors our linter pointed out.

Git gives us an escape hatch to make a commit without running the pre-commit hooks: `git commit --no-verify`.


Imagine we have a pre-commit hook checking for "smelly code"
```console
$ echo "smelly code" > ./test.py
$ git add test.py
$ git commit -m "made some changes"
[Error] 'test.py' contains smelly code!
```
We can force this through
```console
$ git commit --no-verify -m "made some questionable changes"
commit successful
```

We should then run our linter manually at a later time and fix the problems. 
```console
$ mal-code-check ./test.py
[Error] 'test.py' contains smelly code!

$ sed -i 's/smelly/clean/' ./test.py

$ git add test.py
$ git commit -m "cleaned up some smelly code"
commit successful
```

Use this information wisely. It is easy for ignored problems to stack up and snowball.


### pre-commit

`pre-commit` is an overloaded term. It one of many types of hooks git supports and a cli tool
- The pre-commit hook is one of many types of hooks git supports
- The [pre-commit](https://pre-commit.com/) cli tool used for managing git-hooks.
This section focuses on the latter.


Writing our own git-hooks probably isn't nessisary.
Someone else probably has already written the exact hook we want (and to be honest they've probably done it better than we would have).

The `pre-commit` cli tool gives us access to a [collection of third party hooks](https://pre-commit.com/hooks.html).  

Pre commit uses a [.pre-commit-config.yaml](https://pre-commit.com/#plugins) file to tell the `pre-commit` cli tool what linters/formatters we'd like to use every time we create a commit.

Steps:
(Hold off on follwing these steps for now. We are badasses and going to do things a little differently, but it is important to understand the typical flow)
1. Create a `.pre-commit-config.yaml` in the root of our code repo that outlines which checks to run
2. Use the `pre-commit` cli tool to register the hooks with git (this needs to be done every time the `.pre-commit-config.yaml` is modified) with `pre-commit install`

This process is basically an automation for creating git hooks from a yaml file which lists what tools we want to run in the hook.
This takes care of the boiler plate and error handling a good git-hook should have.


#### Caveats
In order to use the tools we've declared in `.pre-commit-config.yaml`, we need to install them.
Depending on your projects, this could mean installing dozens of tools, potentially requiring multiple versions of the same tool for different projects.
The next section will cover a tool to help us with this.

### devenv

#### Intro
This section is about a tool we are going to use, [devenv](https://devenv.sh/) *to manage our .pre-commit-config.yaml* and installed tools.
Abstractions on top of abstractions, such is the world of software.

At first, this is going to seem like a curve ball. To be honest, `devenv` is not 100% nessisary for our use cases, but is going to save us a ton of potential headache.
It is perfectly fair to stop here, backtrack to the `pre-commit` section and manage the pre-commit-config.yaml + install tools oneself.
Bear with me hear, dear reader. I promise we are going somewhere important.


#### Installing devenv
Devenv is built upon [Nix](https://nixos.org/). Nix is a package manager and more.
~~Un~~Fortunally, this means we must install nix.

We can think of devenv as a front-end to nix, [saving us from the perils of installing software ourselves](https://nixos.org/guides/how-nix-works/).
Take my word for it, I don't have time to get into why installing software is a pain.

Basically, if someone has packaged the formatter/linter we want to use for nix, we can trivally install it in with devenv, which will use Nix behind the scenes to do the actual installation.
Devenv (by using nix) guarentees a bullet-proof install of all tools.


##### nix
This is as deep as our rabbit hole goes today.
Nix is an incerdibly powerful tool and covers a scope far outside of our goals in formatting and linting code.
I do not reccomend looking any further into Nix today; it is not beginner friendly.
That being said, Nix (or at least the concepts Nix pionered) is the future of computing...

##### Installing nix
Determinate Systems provides a [nix-installer](https://github.com/DeterminateSystems/nix-installer) that is better than the [official installer](https://nixos.org/download/#download-nix).
Either option is fine, but this guide will procede with the DetSys installer. (not that it matters for us, but [the DetSys installer is on track to become the next version of the official installer](https://github.com/NixOS/experimental-nix-installer))

```console
$ curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

#### Installing devenv (continued)
Now that we have nix, we can use it to install devenv.

```console
$ nix-env -iA devenv -f https://github.com/NixOS/nixpkgs/tarball/nixpkgs-unstable
```


#### Using devenv
Let's create a new project (or open an existing one) to explore devenv

```console
$ mkdir devenv-test
$ cd devenv-test

```

  
Initialize devenv for this project
```console
$ devenv init
```

This will create these files
- .gitignore
- devenv.yaml
- devenv.nix
- .envrc (More on this later in the [direnv](./direnv.md) section)

Commit these files and run `devenv shell` to enter a shell session with all your linters automatically installed to your "${PATH}"

```console
$ which my-linter
not found

$ devenv shell
...

$ which my-linter
/nix/store/scarryhashqndhhxshdb3fk01ymvwpzqw4/my-linter
```
(Ignore the scarry path to the linter. That's the nix store, where nix installs shit to for reasons)


You can run `exit` to deactivate the devshell at any time - its just a shell afterall.


##### direnv
Manually running `direnv shell` and then `exit` later is too much typing. It is too easy to forget to activate the shell, go to use a tool, then get confused as to why its not installed. 
When switching projects, it is also easy to forget to exit the last shell, potentially causing conflicts.

Hypothetically, what if we could `cd` to our project directory, have the dev shell activated automatically,
I'm happy to say there is a solution for that!

`direnv` (unfortuantly, very similar in name to `devenv`) activates/deactivates shells like this exactly.
On top of that, *devenv* has an integration with *direnv*.


##### Installing direnv



## devenv.nix


## devenv resources
- [pre-commit hooks](https://devenv.sh/git-hooks/)
- [devenv.nix intro](https://devenv.sh/basics/)



