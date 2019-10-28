/*
   This file is part of GNOME 2048.

   Copyright (C) 2014-2015 Juan R. García Blanco <juanrgar@gmail.com>
   Copyright (C) 2016-2019 Arnaud Bonatti <arnaud.bonatti@gmail.com>

   GNOME 2048 is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   GNOME 2048 is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with GNOME 2048.  If not, see <https://www.gnu.org/licenses/>.
*/

using Gtk;

private class TwentyFortyEight : Gtk.Application
{
    private GameWindow _window;

    private static bool show_version;

    private const OptionEntry [] option_entries =
    {
        /* Translators: command-line option description, see 'gnome-2048 --help' */
        { "version", 'v', OptionFlags.NONE, OptionArg.NONE, ref show_version, N_("Print release version and exit"), null },
        {}
    };

    private const GLib.ActionEntry [] action_entries =
    {
        { "quit", quit_cb }
    };

    private static int main (string [] args)
    {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);

        OptionContext context = new OptionContext ("");
        context.add_main_entries (option_entries, GETTEXT_PACKAGE);

        context.add_group (get_option_group (true));
        context.add_group (Clutter.get_option_group_without_init ());

        try {
            context.parse (ref args);
        } catch (Error e) {
            stderr.printf ("%s\n", e.message);
            return Posix.EXIT_FAILURE;
        }

        const string application_name = "org.gnome.TwentyFortyEight";
        Environment.set_application_name (application_name);
        Window.set_default_icon_name ("org.gnome.TwentyFortyEight");

        try {
            GtkClutter.init_with_args (ref args, "", new OptionEntry[0], null);
        } catch (Error e) {
            MessageDialog dialog = new MessageDialog (null,
                                                      DialogFlags.MODAL,
                                                      MessageType.ERROR,
                                                      ButtonsType.NONE,
                                                      "Unable to initialize Clutter:\n%s", e.message);
            dialog.set_title (application_name);
            dialog.run ();
            dialog.destroy ();
            return Posix.EXIT_FAILURE;
        }

        TwentyFortyEight app = new TwentyFortyEight ();
        return app.run (args);
    }

    private TwentyFortyEight ()
    {
        Object (application_id: "org.gnome.TwentyFortyEight", flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override int handle_local_options (GLib.VariantDict options)
    {
        if (show_version)
        {
            /* NOTE: Is not translated so can be easily parsed */
            stdout.printf ("%1$s %2$s\n", "gnome-2048", VERSION);
            return Posix.EXIT_SUCCESS;
        }

        /* Activate */
        return -1;
    }

    protected override void startup ()
    {
        base.startup ();

        add_action_entries (action_entries, this);

        _window = new GameWindow (this);

        set_accels_for_action ("ui.toggle-new-game",    {        "<Primary>n"       });
        set_accels_for_action ("ui.new-game",           { "<Shift><Primary>n"       });
        set_accels_for_action ("app.quit",              {        "<Primary>q"       });
        set_accels_for_action ("ui.undo",               {        "<Primary>z"       });
        set_accels_for_action ("ui.about",              {          "<Shift>F1",
                                                          "<Shift><Primary>F1"      }); // as usual, this second shortcut does not work
        set_accels_for_action ("win.show-help-overlay", {                 "F1",
                                                                 "<Primary>F1",
                                                                 "<Primary>question",
                                                          "<Shift><Primary>question"});
        set_accels_for_action ("ui.toggle-hamburger",   {                 "F10",
                                                                          "Menu"    });
    }

    protected override void activate ()
    {
        _window.present ();
    }

    private void quit_cb (/* SimpleAction action, Variant? variant */)
    {
        _window.destroy ();
    }
}
