if exists("g:loaded_mdtree_lib_menu")
    finish
endif
let g:loaded_mdtree_lib_menu = 1


call MDTreeAddMenuItem({'text': '(a)dd a childnode', 'shortcut': 'a', 'callback': 'MDTreeAddNode'})
call MDTreeAddMenuItem({'text': '(d)elete the current node', 'shortcut': 'd', 'callback': 'MDTreeDeleteNode'})

function! MDTreeAddNode()
    let curNode = b:MDTree.root.GetSelected()
    if curNode.isCategory
        let parentNode = curNode
    else
        let parentNode = curNode.parent
    endif
    let newNodeName = input("ChildNode Name\n" , "" , "file")
    if newNodeName ==# ''
        call mdtree#echo("Node creation aborted".)
        return
    endif
python3 << EOF
import vim
import sys
import os
plugin_path = vim.eval('g:plugin_path')
python_module_path = os.path.abspath('%s/../python' % (plugin_path,))
sys.path.append(python_module_path)
docs_path = os.path.join(
    vim.eval('b:MDTree.root.path.pathStr'), "docs")
reader = libreader.MainLib(vim.eval("b:MDTree.libname"))
new_node_name = vim.eval('newNodeName')
pid = vim.eval('parentNode.uuid')
if new_node_name[-1] == '/':
    new_node_name = new_node_name[0:len(new_node_name)-1]
    uuid = str(reader.add_cat(pid, new_node_name))
    vim.command('let uuid = ' + uuid)
    cmd = 'let newNode = g:MDTreeCatNode.New("%s", "%s", curCatNode)' % (new_node_name, uuid)
    vim.command(cmd)
EOF
echo newNode.uuid
echo newNode.name
endfunction

