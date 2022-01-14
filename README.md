# asdf-maven

[Maven](https://en.wikipedia.org/wiki/Apache_Maven)
plugin for the [asdf](https://github.com/asdf-vm/asdf) version manager.

## Install

After installing [asdf](https://github.com/asdf-vm/asdf),
you can add this plugin like this:

```bash
asdf plugin add cobol https://gitee.com/hellomdk/asdf-cobol.git
 chmod -R 755 /root/.asdf/plugins/cobol/bin
```

and install new versions like this:

```bash
asdf install cobol 3.1.2
```

and switch versions like this:

```bash
asdf global cobol 3.1.2
```

and remove plugin like this:

```bash
asdf plugin remove cobol
```

## Reading

Read the [asdf readme](https://github.com/asdf-vm/asdf)
for instructions on how to install and manage versions of any language.

If you have trouble with any expected features,
have any feature requests or want to contribute,
please [do an issue](https://github.com/skotchpine/asdf-maven/issues).

## Development

- asdf's [creating-plugins.md](https://github.com/asdf-vm/asdf/blob/master/docs/creating-plugins.md)
- [Bash Hackers Wiki](http://wiki.bash-hackers.org/)
