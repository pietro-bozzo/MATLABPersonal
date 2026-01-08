function reloadPyEnv()

terminate(pyenv)
configurePyEnv('galvani')
if count(py.sys.path,'/mnt/hubel-data-103/Pietro/Python') == 0
    insert(py.sys.path,int32(0),'/mnt/hubel-data-103/Pietro/Python');
end