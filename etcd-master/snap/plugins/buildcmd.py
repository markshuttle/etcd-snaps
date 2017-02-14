import snapcraft
import subprocess
import shutil
import errno
import os


def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise

class BuildcmdPlugin(snapcraft.BasePlugin):
    """Build a project using a project-specific build command

Some projets include a shell script or other build command, which inspects
and prepares the environment then proceeds to build the project in place.
Instead of using an interpreted build description, these projects expect the
developer to execute that build command. This plugin enables snapcraft to be
told how to setup the environment and then to go ahead and run the command.
Typically, binaries are then copied out of the build tree.

Use these additional keys:

  - install:
    (list of string file paths)
    Files to copy from the src tree into the install tree after the build
    command has been run.

"""


    def __init__(self, name, options, project):
        super().__init__(name, options, project)
        self.build_packages.append('golang-go')
        self._gopath = os.path.join(self.partdir, 'go')
        self._gopath_src = os.path.join(self._gopath, 'src')
        self._gopath_bin = os.path.join(self._gopath, 'bin')
        self._gopath_pkg = os.path.join(self._gopath, 'pkg')


    def _run(self, cmd, **kwargs):
        env = self._build_environment()
        return self.run(cmd, cwd=self.sourcedir, env=env, **kwargs)


    def _build_environment(self):
        env = os.environ.copy()
        env['GOPATH'] = self._gopath

        include_paths = []
        for root in [self.installdir, self.project.stage_dir]:
            include_paths.extend(
                snapcraft.common.get_library_paths(root, self.project.arch_triplet))

        flags = snapcraft.common.combine_paths(include_paths, '-L', ' ')
        env['CGO_LDFLAGS'] = '{} {} {}'.format(
            env.get('CGO_LDFLAGS', ''), flags, env.get('LDFLAGS', ''))

        return env


    @classmethod
    def schema(cls):
        schema = super().schema()
        schema['properties']['cmd'] = {
            'type': 'string',
            'default': ''
        }

        return schema

    def build(self):
        print('Running build command...')
        self._run([self.options.cmd])
        for path in self.options.install:
            from_path = os.path.join(self.sourcedir, path)
            if not os.path.isfile(from_path):
                raise FileNotFoundError(
                    errno.ENOENT, os.strerror(errno.ENOENT), from_path)
            to_path = os.path.join(self.installdir, path)
            mkdir_p(os.path.dirname(to_path))
            shutil.copy(from_path, to_path)

