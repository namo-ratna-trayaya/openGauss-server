/* -------------------------------------------------------------------------
 *
 * dropdb
 *
 * Portions Copyright (c) 1996-2012, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 * src/bin/scripts/dropdb.c
 *
 * -------------------------------------------------------------------------
 */
#include "postgres_fe.h"
#include "common.h"
#include "dumputils.h"

static void help(const char* progname_tem);

int main(int argc, char* argv[])
{
    static int if_exists = 0;

    static struct option long_options[] = {{"host", required_argument, NULL, 'h'},
        {"port", required_argument, NULL, 'p'},
        {"username", required_argument, NULL, 'U'},
        {"no-password", no_argument, NULL, 'w'},
        {"password", no_argument, NULL, 'W'},
        {"echo", no_argument, NULL, 'e'},
        {"interactive", no_argument, NULL, 'i'},
        {"if-exists", no_argument, &if_exists, 1},
        {"maintenance-db", required_argument, NULL, 2},
        {NULL, 0, NULL, 0}};

    const char* progname_tem = NULL;
    int optindex;
    int c;

    char* dbname_tem = NULL;
    const char* maintenance_db = NULL;
    char* host = NULL;
    char* port = NULL;
    char* username = NULL;
    enum trivalue prompt_password = TRI_DEFAULT;
    bool echo = false;
    bool interactive = false;

    PQExpBufferData sql;

    PGconn* conn = NULL;
    PGresult* result = NULL;

    progname_tem = get_progname(argv[0]);
    set_pglocale_pgservice(argv[0], PG_TEXTDOMAIN("pgscripts"));

    handle_help_version_opts(argc, argv, "dropdb", help);

    while ((c = getopt_long(argc, argv, "h:p:U:wWei", long_options, &optindex)) != -1) {
        switch (c) {
            case 'h':
                host = optarg;
                break;
            case 'p':
                port = optarg;
                break;
            case 'U':
                username = optarg;
                break;
            case 'w':
                prompt_password = TRI_NO;
                break;
            case 'W':
                prompt_password = TRI_YES;
                break;
            case 'e':
                echo = true;
                break;
            case 'i':
                interactive = true;
                break;
            case 0:
                /* this covers the long options */
                break;
            case 2:
                maintenance_db = optarg;
                break;
            default:
                fprintf(stderr, _("Try \"%s --help\" for more information.\n"), progname_tem);
                exit(1);
        }
    }

    switch (argc - optind) {
        case 0:
            fprintf(stderr, _("%s: missing required argument database name\n"), progname_tem);
            fprintf(stderr, _("Try \"%s --help\" for more information.\n"), progname_tem);
            exit(1);
        case 1:
            dbname_tem = argv[optind];
            break;
        default:
            fprintf(stderr, _("%s: too many command-line arguments (first is \"%s\")\n"), progname_tem, argv[optind + 1]);
            fprintf(stderr, _("Try \"%s --help\" for more information.\n"), progname_tem);
            exit(1);
    }

    if (interactive) {
        printf(_("Database \"%s\" will be permanently removed.\n"), dbname_tem);
        if (!yesno_prompt("Are you sure?"))
            exit(0);
    }

    initPQExpBuffer(&sql);

    appendPQExpBuffer(&sql, "DROP DATABASE %s%s;\n", (if_exists ? "IF EXISTS " : ""), fmtId(dbname_tem));

    /* Avoid trying to drop postgres db while we are connected to it. */
    if (maintenance_db == NULL && strcmp(dbname_tem, "postgres") == 0)
        maintenance_db = "template1";

    conn = connectMaintenanceDatabase(maintenance_db, host, port, username, prompt_password, progname_tem);

    if (echo)
        printf("%s", sql.data);
    result = PQexec(conn, sql.data);
    if (PQresultStatus(result) != PGRES_COMMAND_OK) {
        fprintf(stderr, _("%s: database removal failed: %s"), progname_tem, PQerrorMessage(conn));
        PQfinish(conn);
        exit(1);
    }

    PQclear(result);
    PQfinish(conn);
    exit(0);
}

static void help(const char* progname_tem)
{
    printf(_("%s removes a PostgreSQL database.\n\n"), progname_tem);
    printf(_("Usage:\n"));
    printf(_("  %s [OPTION]... DBNAME\n"), progname_tem);
    printf(_("\nOptions:\n"));
    printf(_("  -e, --echo                show the commands being sent to the server\n"));
    printf(_("  -i, --interactive         prompt before deleting anything\n"));
    printf(_("  -V, --version             output version information, then exit\n"));
    printf(_("  --if-exists               don't report error if database doesn't exist\n"));
    printf(_("  -?, --help                show this help, then exit\n"));
    printf(_("\nConnection options:\n"));
    printf(_("  -h, --host=HOSTNAME       database server host or socket directory\n"));
    printf(_("  -p, --port=PORT           database server port\n"));
    printf(_("  -U, --username=USERNAME   user name to connect as\n"));
    printf(_("  -w, --no-password         never prompt for password\n"));
    printf(_("  -W, --password            force password prompt\n"));
    printf(_("  --maintenance-db=DBNAME   alternate maintenance database\n"));
    printf(_("\nReport bugs to <pgsql-bugs@postgresql.org>.\n"));
}
