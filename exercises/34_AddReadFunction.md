# Add Write functionality to your App

In this exercise lets use Claude to adds a basic `Read from POD functionality` to the existing app in simplistic way.

## Get the Claude to analyse the existing code base and write CALUDE.md

First thing you need to do is ask the Claude to analyse your existing code and get a basic
understanding of the current functionality of the app. You will also need to generate a file
called CLAUDE.md

### What is CLAUDE.md?

CLAUDE.md is a markdown file used by Claude Code. It's a project-context file that Claude
Code automatically reads at the start of every session, so you don't have to re-explain the 
same background every time. it can hold anything you like from coding standards, architecture decisions to and review checklists.

### Generate CLAUDE.md

The easiest way is with the built-in `/init` command in Claude Code. Open Claude in your project directory and run the command,

```bash
\init
```

However, a better and more personalised way is to ask the Claude to generate CLAUDE.md with your exact requirements.

You could use something like the following to ask Claude to create CLAUDE.md.

```text
Analyse this codebase and create a CLAUDE.md file following below principles:

1. Keep it under 300 lines total focusing only on universally applicable information
2. Cover the essentials: WHAT (tech stack, project structure), WHY (purpose), and HOW (build/test commands)
3. Use Progressive Disclosure: instead of including all instructions, create a brief index pointing to other markdown files in .claude/docs/ for specialised topics
4. Include file:line references instead of code snippets

Structure it as: project overview, tech stack, key directories/their purposes, and a list of additional documentation files Claude should check when relevant.

If needed ask me about any clarifications required.
```

Feel free to add your own requirements to the above based on your coding style. Once you give these instructions to Claude, it will analyse the codebase and create the CLAUDE.md with relevant details.

## Ask the Claude to build the Read functionality

Now let's ask Claude to implement the Read functionality within our app. First change the running mode to `Plan mode` in Claude. Then use the following simple prompt or create your own to ask Claude to write a plan to implement the functionality.

```text
The app already has an "Add Note" page (lib/screens/add_note.dart) that saves a title + description as JSON string into an encrypted file named `note_<timestamp>.json.enc.ttl` in the app's POD data directory, using writePod().

Now add a basic Read function to the app:

1. Create a new page `lib/screens/view_notes.dart` that, on load, lists every note file in the app's POD data directory and shows each one's title and created time in a simple list (e.g. a `Card` per note).
2. Use functionalities available in solidpod and solidui libraries such as `readPod()` to read and decrypt each data file. Parse the returned string back from JSON.
3. Show a loading indicator while fetching, and handle errors (not logged in, read/decrypt failure) with a snackbar.
4. When clicked on a note card, show a popup dialog with note title and description.
5. Wire the new page into the app's `SolidScaffold` menu (see lib/app_scaffold.dart) as a new "View Notes" entry, next to "Add Note".

Follow the same code style, error-handling patterns, and widget structure already
used in the exisiting codebase.
 
```

Since you are in `plan` mode Claude with create a plan to add this function to your codebase. Review the plan and ask Claude to execute.

Now restart the app and test your newly implemented functionality.

Congratulations! You have now successfully implemented a functionality to read data from PODs.