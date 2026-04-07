function cpp-new --description 'Create a new C++ project from template'
    if test -z "$argv[1]"
        echo "Usage: cpp-new <project-name>"
        return 1
    end

    set project_name $argv[1]

    git clone https://github.com/mepatrick73/cpp-template $project_name
    cd $project_name
    rm -rf .git
    git init
    git add .
    git commit -m "initial commit"

    cmake --preset debug
end
