# =============================================================================
# Python Aliases
# =============================================================================
# Python is a programming language. These aliases save typing for common
# Python development tasks.

alias py='python'                     # Short way to run the Python interpreter
alias pip='python -m pip'             # Install Python packages (using "python -m pip" is safer
                                      # than bare "pip" because it ensures you're using the
                                      # right Python version's pip)
alias venv='python -m venv'           # Create a virtual environment (an isolated sandbox for
                                      # a project's dependencies so they don't clash with others)
alias activate='source venv/bin/activate'  # Activate the virtual environment in the current folder
                                           # (after this, "python" and "pip" only affect this project)
