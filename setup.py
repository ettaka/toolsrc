#!/usr/bin/env python

import subprocess
import os

home_dir = os.path.expanduser("~")  
working_dir = os.getcwd()
nvim_install_dir = home_dir + "/bin"
nvim_conf_path = home_dir + "/.config/nvim"
nvim_init_path = nvim_conf_path + "/init.vim"
nvim_init_target = working_dir + "/nvim/init.vim"
vimplug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
tmux_conf_target = working_dir + "/tmux/tmux.conf"
tmux_conf_path = home_dir + "/.tmux.conf"

def e(cmd):
	proc = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
	return proc.stdout.read()

def git_version():
	try:
		return e('git --version')
	except:
		return None

def makedir(dir): 
    if not os.path.exists(dir): 
            os.makedirs(dir)
            return True
    return False

def create_nvim_conf_path():
	print "Creating Nvim configuration path", nvim_conf_path, "...",
	if not makedir(nvim_conf_path): print "already exists"
	else: print

def create_nvim_init_symlink():
	print "Creating a symbolic link", nvim_init_path, "to target", nvim_init_target, "...", 
	if not os.path.isfile(nvim_init_path):
		e('ln -s ' + nvim_init_target + ' ' + nvim_init_path)
		print
	else:
		print "already exists"

def install_nvim_appimage(install_path):
	print "Creating nvim install path", install_path, "...",
	if not makedir(install_path): print "already exists"
	print "Installing Nvim Appimage...", 
	if not os.path.isfile(install_path + '/nvim.appimage'):
		try:
			e('curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage')
		except:
			print "Problem with fetching, check if curl works accordingly."
			exit()
		e('mv nvim.appimage ' + install_path) 
		e('chmod u+x ' + install_path + '/nvim.appimage')
		e('ln -s ' + install_path + '/nvim.appimage ' + install_path + '/nvim')
	
	else:
		print "already exists"


def install_vim_plug():
    autoload_dir = nvim_conf_path + '/autoload'
    vimplug_file_path = autoload_dir + '/plug.vim'
    print "Fetching plug.vim at", vimplug_url, "...",
    if not os.path.isfile(vimplug_file_path):
        try:
            e('curl -LO ' + vimplug_url)
        except:
            print "Problems with fetching, check if curl works accordingly."
            exit()
        makedir(autoload_dir)
        e('mv plug.vim ' + autoload_dir)
    else:
        print "already exists"
                
    if not os.path.isfile(vimplug_file_path):
        print "A problem with fetching the vim.plug file"
        exit()

def set_tmux_conf_symlink():
    print "Setting tmux config file symlink", tmux_conf_path, "target to", tmux_conf_target, "...",
    if os.path.isfile(tmux_conf_path):
        print "already set"
    else:
        e('ln -s ' + tmux_conf_target + ' ' + tmux_conf_path)


if git_version() == None:
	print "Git is not found! Exiting..."
	exit()

create_nvim_conf_path()
create_nvim_init_symlink()
install_nvim_appimage(nvim_install_dir)
install_vim_plug()
set_tmux_conf_symlink()

