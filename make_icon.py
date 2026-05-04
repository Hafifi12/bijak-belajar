from PIL import Image, ImageDraw, ImageFont
import math, os

size = 1024
img = Image.new('RGBA', (size, size), (0,0,0,0))
draw = ImageDraw.Draw(img)

# Rich purple radial background
for i in range(size//2, 0, -1):
    ratio = i / (size//2)
    r = int(80 + 40*ratio)
    g = int(60 + 40*ratio)
    b = int(200 + 40*ratio)
    draw.ellipse([size//2-i, size//2-i, size//2+i, size//2+i], fill=(r,g,b,255))

# Outer glow rings
draw.ellipse([30,30,994,994], outline=(255,255,255,60), width=18)
draw.ellipse([50,50,974,974], outline=(255,255,255,30), width=8)

# White book body
bx, by = 170, 240
bw, bh = 684, 500
draw.rounded_rectangle([bx, by, bx+bw, by+bh], radius=72, fill=(255,255,255,255))

# Book spine
spine_x = bx + bw//2
draw.rectangle([spine_x-10, by+50, spine_x+10, by+bh-50], fill=(108,92,231,160))

# Left page lines
for i in range(4):
    y = by + 130 + i*78
    w2 = 180 - i*20
    draw.rounded_rectangle([bx+55, y, bx+55+w2, y+18], radius=9, fill=(180,170,240,200))

# Right page lines
for i in range(4):
    y = by + 130 + i*78
    w2 = 180 - i*20
    draw.rounded_rectangle([spine_x+35, y, spine_x+35+w2, y+18], radius=9, fill=(180,170,240,200))

# Star rays above book
cx, cy_star = size//2, by - 30
for j in range(8):
    angle = j * math.pi/4
    x1 = cx + 30*math.cos(angle)
    y1 = cy_star + 30*math.sin(angle)
    x2 = cx + 90*math.cos(angle)
    y2 = cy_star + 90*math.sin(angle)
    draw.line([x1,y1,x2,y2], fill=(255,220,50,180), width=6)

# Big yellow star
sr = 75
star_pts = []
for j in range(10):
    angle = -math.pi/2 + j * 2*math.pi/10
    r2 = sr if j%2==0 else sr*0.40
    star_pts.append((cx + r2*math.cos(angle), cy_star + r2*math.sin(angle)))
draw.polygon(star_pts, fill=(255,214,0,255))
draw.polygon(star_pts, outline=(255,170,0,255), width=4)

# Small corner stars
for (sx,sy,ss) in [(160,160,28),(860,190,22),(150,820,18),(880,810,24),(500,170,16)]:
    spts=[]
    for j in range(10):
        angle=-math.pi/2+j*2*math.pi/10
        r3=ss if j%2==0 else ss*0.4
        spts.append((sx+r3*math.cos(angle),sy+r3*math.sin(angle)))
    draw.polygon(spts, fill=(255,214,0,200))

# 'BB' letters
try:
    font_b = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 200)
    font_tag = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 42)
except:
    try:
        font_b = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 200)
        font_tag = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 42)
    except:
        font_b = ImageFont.load_default()
        font_tag = font_b

draw.text((bx+145, by+190), 'B', fill=(108,92,231,255), font=font_b)
draw.text((spine_x+55, by+190), 'B', fill=(108,92,231,255), font=font_b)
draw.text((cx, by+bh-55), 'BELAJAR  BIJAK', fill=(140,120,220,220), font=font_tag, anchor='mm')

# Corner dots
for (dx,dy) in [(200,870),(824,870),(200,154),(824,154)]:
    draw.ellipse([dx-12,dy-12,dx+12,dy+12], fill=(255,214,0,200))

os.makedirs('assets/icons', exist_ok=True)
img.save('assets/icons/app_icon.png')
print('app_icon.png saved')

# Foreground (no background circle — for adaptive icon)
fg = Image.new('RGBA', (size, size), (0,0,0,0))
fgd = ImageDraw.Draw(fg)
fgd.rounded_rectangle([bx,by,bx+bw,by+bh], radius=72, fill=(255,255,255,255))
fgd.rectangle([spine_x-10,by+50,spine_x+10,by+bh-50], fill=(108,92,231,160))
for i in range(4):
    y=by+130+i*78; w2=180-i*20
    fgd.rounded_rectangle([bx+55,y,bx+55+w2,y+18], radius=9, fill=(180,170,240,200))
    fgd.rounded_rectangle([spine_x+35,y,spine_x+35+w2,y+18], radius=9, fill=(180,170,240,200))
spts2=[]
for j in range(10):
    angle=-math.pi/2+j*2*math.pi/10
    r2=sr if j%2==0 else sr*0.40
    spts2.append((cx+r2*math.cos(angle),cy_star+r2*math.sin(angle)))
fgd.polygon(spts2, fill=(255,214,0,255))
fgd.text((bx+145,by+190),'B',fill=(108,92,231,255),font=font_b)
fgd.text((spine_x+55,by+190),'B',fill=(108,92,231,255),font=font_b)
fgd.text((cx,by+bh-55),'BELAJAR  BIJAK',fill=(140,120,220,220),font=font_tag,anchor='mm')
fg.save('assets/icons/app_icon_foreground.png')
print('app_icon_foreground.png saved')
print('All done!')
