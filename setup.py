#!/usr/bin/env python

import subprocess
import os
import fileinput

vimscript=False
home_dir = os.path.expanduser("~")  
working_dir = os.getcwd()
nvim_install_dir = home_dir + "/bin"
nvim_conf_path = home_dir + "/.config/nvim"
if vimscript:
    nvim_init_path = nvim_conf_path + "/init.vim"
    nvim_init_target = working_dir + "/nvim/init.vim"
else:
    nvim_init_path = nvim_conf_path
    nvim_init_target = working_dir + "/nvim-lua"
vimplug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
tmux_conf_target = working_dir + "/tmux/tmux.conf"
tmux_conf_path = home_dir + "/.tmux.conf"
bashrc_path = home_dir + "/.bashrc"
zshrc_path = home_dir + "/.zshrc"
i3_config_path = home_dir + "/.config/i3/config"
i3_config_target = working_dir + "/i3/config"

def e(cmd):
    if type(cmd) == type([]):
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    else:
        proc = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
    return proc.stdout.read()

def version(program='git'):
    try:
        if program == 'git':
            return e('git --version')
        elif program == 'zsh':
            return e('zsh --version')
        elif program == 'curl':
            return e('curl --version')
    except:
            return None

def require(program='git'):
    if program == 'git':
        if version('git') == None:
            print("Git not found! Install it and try again.")
            exit()
    elif program == 'zsh':
        if version('zsh') == None:
            print("Zsh not found! Install it and try again.")
            exit()
    elif program == 'curl':
        if version('curl') == None:
            print("Curl not found! Install it and try again.")
            exit()
        
def makedir(dir): 
    if not os.path.exists(dir): 
            os.makedirs(dir)
            return True
    return False

def create_nvim_conf_path():
    if vimscript:
        print("Creating Nvim configuration path", nvim_conf_path, "...", end=' ')
        if not makedir(nvim_conf_path): print("already exists")
        else: print()

def create_nvim_init_symlink():
    print("Creating a symbolic link", nvim_init_path, "to target", nvim_init_target, "...", end=' ') 
    if not os.path.isfile(nvim_init_path):
            e('ln -s ' + nvim_init_target + ' ' + nvim_init_path)
            print()
    else:
            print("already exists")

def install_nvim_appimage(install_path):
    require('curl') 
    print("Creating nvim install path", install_path, "...", end=' ')
    if not makedir(install_path): print("already exists")
    print("Installing Nvim Appimage...", end=' ') 
    if not os.path.isfile(install_path + '/nvim.appimage'):
        print()
        try:
            e('curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage')
        except:
            print("Problem with fetching, check if curl works accordingly.")
            exit()
        e('mv nvim.appimage ' + install_path) 
        e('chmod u+x ' + install_path + '/nvim.appimage')
        e('ln -s ' + install_path + '/nvim.appimage ' + install_path + '/nvim')

    else:
        print("already exists")


def install_vim_plug():
    require('curl') 
    autoload_dir = nvim_conf_path + '/autoload'
    vimplug_file_path = autoload_dir + '/plug.vim'
    print("Fetching plug.vim at", vimplug_url, "...", end=' ')
    if not os.path.isfile(vimplug_file_path):
        print()
        try:
            e('curl -LO ' + vimplug_url)
        except:
            print("Problems with fetching, check if curl works accordingly.")
            exit()
        makedir(autoload_dir)
        e('mv plug.vim ' + autoload_dir)
    else:
        print("already exists")
                
    if not os.path.isfile(vimplug_file_path):
        print("A problem with fetching the vim.plug file")
        exit()

def install_packer():
    require('git')
    try:
        e('git clone --depth 1 https://github.com/wbthomason/packer.nvim {}/.local/share/nvim/site/pack/packer/start/packer.nvim'.format(home_dir))
    except:
        print("Problems with cloning https://github.com/wbthomason/packer.nvim")
        print("Please check the URL.")

def set_tmux_conf_symlink():
    print("Setting tmux config file symlink", tmux_conf_path, "target to", tmux_conf_target, "...", end=' ')
    if os.path.isfile(tmux_conf_path):
        print("already set")
    else:
        e('ln -s ' + tmux_conf_target + ' ' + tmux_conf_path)
        print()

def shellrc_not_set(shell='bash'):
    if shell == 'bash':
        with open(bashrc_path, 'r') as bashrc:
            content = bashrc.readlines()
        if len([line for line in content if "# toolsrc set" in line])==0: return True
    elif shell == 'zsh':
        with open(zshrc_path, 'r') as bashrc:
            content = bashrc.readlines()
        if len([line for line in content if "# toolsrc set" in line])==0: return True
    return False
    
def set_shellrc(shell='bash'):
    if shell == 'bash':
        print("Setting bashrc ...", end=' ') 
        if shellrc_not_set('bash'):
            bashrc = open(bashrc_path, "a")
            bashrc.write("# toolsrc set (don't remove this comment line unless you remove all that is set by toolsrc setup script)\n")
            bashrc.write("TOOLSRC_DIR=" + working_dir + "\n")
            bashrc.write("for BASHFILE in $(ls $TOOLSRC_DIR/bash)\n")
            bashrc.write("do\n")
            bashrc.write("    source $TOOLSRC_DIR/bash/$BASHFILE\n")
            bashrc.write("done\n")
            bashrc.write("# end of toolsrc settings\n")
        else:
            print("already set")
    if shell == 'zsh':
        require('zsh')
        print("Setting up zsh")
        if not os.path.exists(home_dir + "/.oh-my-zsh"):
            require('curl') 
            require('git') 
            print("Installing oh-my-zsh...")
            try:
                e('wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh')
                e('sh install.sh')
                #e(['sh','-c','"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'])
                print("oh-my-zsh installed, zsh is set as default and will be actived next time you login")
            except:
                print("oh-my-zsh install failed")
        else:
            print("oh-my-zsh already installed, remove ~/.oh-my-zsh in order to reinstall.")

        if shellrc_not_set('zsh'):
            rc = open(zshrc_path, "a")
            rc.write("# toolsrc set (don't remove this comment line unless you remove all that is set by toolsrc setup script)\n")
            rc.write("TOOLSRC_DIR=" + working_dir + "\n")
            rc.write("for SHFILE in $(ls $TOOLSRC_DIR/zsh)\n")
            rc.write("do\n")
            rc.write("    source $TOOLSRC_DIR/zsh/$SHFILE\n")
            rc.write("done\n")
            rc.write("# end of toolsrc settings\n")
        else:
            print("zshrc already set by toolsrc setup")

def set_i3_config_symlink():
    print("Setting i3 config file symlink", i3_config_path, "target to", i3_config_target, "...", end=' ')
    if os.path.isfile(i3_config_path):
        print("Already set. Removing...")
        e('rm ' + i3_config_path)
    e('ln -s ' + i3_config_target + ' ' + i3_config_path)
    print()

create_nvim_conf_path()
create_nvim_init_symlink()
install_nvim_appimage(nvim_install_dir)
if vimscript:
    install_vim_plug()
else:
    install_packer()
set_tmux_conf_symlink()
set_shellrc('bash')
set_shellrc('zsh')
set_i3_config_symlink()
