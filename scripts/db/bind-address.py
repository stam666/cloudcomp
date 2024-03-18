config_path = "/etc/mysql/mariadb.conf.d/50-server.cnf"

def main():
    contents = ""
    with open(config_path, "r") as f:
        lines = f.readlines()
        for i in range(len(lines)):
            if "bind-address" in lines[i]:
                lines[i] = "bind-address = " + "0.0.0.0" + "\n"
                break
        contents = "".join(lines)

    with open(config_path, "w") as wf:
        wf.write(contents)

if __name__ == "__main__":
    main()