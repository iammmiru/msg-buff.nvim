# msg-buff.nvim

Messages from neovim are fleeting and clumsy. With `:messages`, you can't easily yank the lines.
So, I created a very simple plugin for displaying messages in a floating buffer.

## Installation
Use your favorite plugin manager. For example, with `lazy.nvim`:

```lua
{
  'iammmiru/msg-buff.nvim',
  config = function()
    require('msg-buff').setup({})
  end
}
```

## Usage
Run the command:

```
:MsgBuff
```

## Default Configuration

```lua
{
  width = 0.7,
  height = 0.5,
  border = 'rounded',
  show_number = vim.o.number,
  show_relativenumber = vim.o.relativenumber,
  normal_hl = 'Normal',
  border_hl = 'FloatBorder',
}
```

## License
MIT
