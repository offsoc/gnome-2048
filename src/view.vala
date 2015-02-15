/* Copyright (C) 2014-2015 Juan R. García Blanco
 *
 * This file is part of GNOME 2048.
 *
 * GNOME 2048 is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * GNOME 2048 is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with GNOME 2048; if not, see <http://www.gnu.org/licenses/>.
 */

public class RoundedRectangle : GLib.Object
{
  protected Clutter.Actor _actor;
  protected Clutter.Canvas _canvas;
  protected Clutter.Color? _color;

  public RoundedRectangle (float x, float y, float width, float height, Clutter.Color? color)
  {
    Object ();

    _color = color;

    _canvas = new Clutter.Canvas ();
    _canvas.set_size ((int)Math.ceilf (width), (int)Math.ceilf (height));

    _actor = new Clutter.Actor ();
    _actor.set_size (width, height);
    _actor.set_content (_canvas);
    _actor.x = x;
    _actor.y = y;
    _actor.set_pivot_point (0.5f, 0.5f);
    _actor.allocation_changed.connect (_on_allocation_changed);

    _canvas.draw.connect (_draw);
  }

  private void _on_allocation_changed (Clutter.ActorBox box, Clutter.AllocationFlags flags)
  {
    debug ("allocation changed");
  }

  public Clutter.Actor actor {
    get { return _actor; }
  }

  public Clutter.Color color {
    get { return _color; }
    set {
      _color = value;
      _canvas.invalidate ();
    }
  }

  public Clutter.Canvas canvas {
    get { return _canvas; }
  }

  public void resize (float x, float y, float width, float height)
  {
    _actor.x = x;
    _actor.y = y;
    _actor.width = width;
    _actor.height = height;
  }

  public void idle_resize ()
  {
    if (!_canvas.set_size ((int)Math.ceilf (_actor.width), (int)Math.ceilf (_actor.height)))
      _canvas.invalidate ();
  }

  protected virtual bool _draw (Cairo.Context ctx, int width, int height)
  {
    double radius = height / 20.0;
    double degrees = Math.PI / 180.0;

    ctx.save ();
    ctx.set_operator (Cairo.Operator.CLEAR);
    ctx.paint ();
    ctx.restore ();

    ctx.new_sub_path ();
    ctx.arc (width - radius, radius, radius, -90 * degrees, 0 * degrees);
    ctx.arc (width - radius, height - radius, radius, 0 * degrees, 90 * degrees);
    ctx.arc (radius, height - radius, radius, 90 * degrees, 180 * degrees);
    ctx.arc (radius, radius, radius, 180 * degrees, 270 * degrees);
    ctx.close_path ();

    if (_color != null) {
      Clutter.cairo_set_source_color (ctx, _color);
      ctx.fill ();
    }

    return false;
  }
}

public class TileView : RoundedRectangle
{
  public TileView (float x, float y, float width, float height, uint val)
  {
    base (x, y, width, height, null);

    _value = val;
    _color = _pick_color ();
  }

  public uint value {
    get; set; default = 2;
  }


  protected override bool _draw (Cairo.Context ctx, int width, int height)
  {
    Pango.Rectangle logical_rect;
    Pango.Layout layout;
    Pango.FontDescription font_desc;

    base._draw (ctx, width, height);

    ctx.set_source_rgb (255, 255, 255);

    layout = Pango.cairo_create_layout (ctx);
    font_desc = Pango.FontDescription.from_string ("Sans Bold %dpx".printf (height / 4));
    layout.set_font_description (font_desc);

    layout.set_text (value.to_string(), -1);

    layout.get_extents (null, out logical_rect);
    ctx.move_to ((width / 2) - (logical_rect.width / 2 / Pango.SCALE),
                 (height / 2) - (logical_rect.height / 2 / Pango.SCALE));
    Pango.cairo_show_layout (ctx, layout);

    return false;
  }

  private Clutter.Color _pick_color ()
  {
    return ColorPalette.get_instance ().pick_color (_value);
  }
}

public class ColorPalette : GLib.Object
{
  private Gee.HashMap<uint,Clutter.Color?> _palette;
  private static ColorPalette? _singleton = null;

  public ColorPalette ()
  {
    Object ();

    _palette = new Gee.HashMap<uint,Clutter.Color?> ();

    _palette.set (2,    Clutter.Color.from_string ("#fce94f")); // Butter 1
    _palette.set (4,    Clutter.Color.from_string ("#8ae234")); // Chameleon 1
    _palette.set (8,    Clutter.Color.from_string ("#fcaf3e")); // Orange 1
    _palette.set (16,   Clutter.Color.from_string ("#729fcf")); // Sky blue 1
    _palette.set (32,   Clutter.Color.from_string ("#ad7fa8")); // Plum 1
    _palette.set (64,   Clutter.Color.from_string ("#e9b96e")); // Chocolate 1
    _palette.set (128,  Clutter.Color.from_string ("#ef2929")); // Scarlet red 1
    _palette.set (256,  Clutter.Color.from_string ("#c4a000")); // Butter 3
    _palette.set (512,  Clutter.Color.from_string ("#4e9a06")); // Chameleon 3
    _palette.set (1024, Clutter.Color.from_string ("#ce5c00")); // Orange 3
    _palette.set (2048, Clutter.Color.from_string ("#204a87")); // Sky blue 3
  }

  public static ColorPalette get_instance ()
  {
    if (_singleton == null) {
      ColorPalette._singleton = new ColorPalette ();
    }

    return _singleton;
  }

  public Clutter.Color pick_color (uint val)
  {
    Clutter.Color color;

    if (_palette.has_key (val)) {
      color = _palette.get (val);
    } else {
      uint norm_val;
      uint8 sbits;

      norm_val = val / 2048;
      color = _palette.get (norm_val);

      sbits = (uint8)(val % 7);
      color.red <<= sbits;
      color.green <<= sbits;
      color.blue <<= sbits;
    }

    return color;
  }
}
