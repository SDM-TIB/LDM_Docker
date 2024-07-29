import sys


# File path to save the list of string values
# Maximal amount of guest user max_val
def generate_list_user(*args):
    max_val, file_path = int(args[0]), args[1]
    list_user = ["guest" + str(i) + "\n" for i in range(0, max_val)]

    # Write the user name to the file
    with open(file_path, "w") as file:
        file.writelines(list_user)


if __name__ == '__main__':
    generate_list_user(*sys.argv[1:])