# Wrapptainer

Wrapptainer is just a little bash wrapper script to save time when running apptainer on bioinformatics tools. It's not super fancy or rigorously tested.

Nice things it does do:
- Provides a preset list of bioinfo containers that is simple to update and add to.
- Automatically finds all the bind points to your files in your command (yes, even symlinks work).
- Prints out a nice little overview of your software versions and the full command to run.
- Allows a dry run of the command so you can see if it's doing what you expect.


## Use

The only prereq for wrapptainer is apptainer. If you've never used it, try it out a bit before using wrapptainer.

To use wrapptainer:

```{bash}
./wrapptainer.sh [wrapptainer args...] <tool> [tool args...]
```

Note: wrapptainer args must go before the tool name you're using or they will not work (thank goodness because some tools will use -i -t -d -q in the tool args...).

You might want to just make an alias in one of your .bashrc or other alias specific config file that gets sourced, similar to this:

```{bash}
alias appy="<YOUR PATH TO APPY SCRIPT>/wrapptainer.sh"
```

### Wrapptainer args

You don't have to supply parameters for many tools, but for some you will need to.

The `run_type` param allows other apptainer commands outside of "exec".
```
r (run_type: [exec|run|shell]; default "exec")
```

The following flags can be added (no words after them, just flags).
```
q (quiet: FLAG; default behavior is off)
i (ignore_command: FLAG; default behavior is off)
d (dry_run: FLAG; default behavior is off)
```


### Examples

Get samtools version:
```{bash}
appy samtools --version
```

Get a dry run of the above command (just prints, doesn't run apptainer):
```{bash}
appy -d samtools --version
```

Shell into the fastqc image:
```{bash}
appy -r shell fastqc
```

Get helixer version (note how -i allows scripts inside container to run):
```{bash}
appy -i helixer Helixer.py
```

Run bwa index, quietly (note how -q prevents wrapptainer from being yapptainer):
```{bash}
appy -q bwa index test.fna > log.txt
```

## Config files
### Container images
The conf/images.conf file has images. Just look at it and you'll see how you can easily add another.

### Special container options
The conf/special.conf file has special container options you might need for some tools.

For example, helixer needs `--nv` to run GPU mode.

## Limitations

Wrapptainer can't do everything.

Current limitations are:
- No piping between images.
- If -q is not used, wrapptainer will write to stderr, which is not ideal for having a "pure" logfile

