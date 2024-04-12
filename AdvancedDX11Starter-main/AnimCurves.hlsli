#define PI 3.14159265358979323846

#define EASE_IN_SINE 0
#define EASE_OUT_SINE 1
#define EASE_IN_OUT_SINE 2
#define EASE_IN_QUAD 3
#define EASE_OUT_QUAD 4
#define EASE_IN_OUT_QUAD 5
#define EASE_IN_CUBIC 6
#define EASE_OUT_CUBIC 7
#define EASE_IN_OUT_CUBIC 8
#define EASE_IN_QUART 9
#define EASE_OUT_QUART 10
#define EASE_IN_OUT_QUART 11
#define EASE_IN_QUINT 12
#define EASE_OUT_QUINT 13
#define EASE_IN_OUT_QUINT 14
#define EASE_IN_EXPO 15
#define EASE_OUT_EXPO 16
#define EASE_IN_OUT_EXPO 17
#define EASE_IN_CIRC 18
#define EASE_OUT_CIRC 19
#define EASE_IN_OUT_CIRC 20
#define EASE_IN_BACK 21
#define EASE_OUT_BACK 22
#define EASE_IN_OUT_BACK 23
#define EASE_IN_ELASTIC 24
#define EASE_OUT_ELASTIC 25
#define EASE_IN_OUT_ELASTIC 26
#define EASE_IN_BOUNCE 27
#define EASE_OUT_BOUNCE 28
#define EASE_IN_OUT_BOUNCE 29

float EaseInSine(float x)
{
    return 1.0 - cos((x * PI) / 2.0);
}

float EaseOutSine(float x)
{
    return sin((x * PI) / 2.0);
}

float EaseInOutSine(float x)
{
    return -(cos(PI * x) - 1.0) / 2.0;
}

float EaseInQuad(float x)
{
    return x * x;
}

float EaseOutQuad(float x)
{
    return 1.0 - (1.0 - x) * (1.0 - x);
}

float EaseInOutQuad(float x)
{
    return x < 0.5 ? 2.0 * x * x : 1.0 - pow(-2.0 * x + 2.0, 2.0) / 2.0;
}

float EaseInCubic(float x)
{
    return x * x * x;
}

float EaseOutCubic(float x)
{
    return 1.0 - pow(1.0 - x, 3.0);
}

float EaseInOutCubic(float x)
{
    return x < 0.5 ? 4.0 * x * x * x : 1.0 - pow(-2.0 * x + 2.0, 3.0) / 2.0;
}

float EaseInQuart(float x)
{
    return x * x * x * x;
}

float EaseOutQuart(float x)
{
    return 1.0 - pow(1.0 - x, 4.0);
}

float EaseInOutQuart(float x)
{
    return x < 0.5 ? 8.0 * x * x * x * x : 1.0 - pow(-2.0 * x + 2.0, 4.0) / 2.0;
}

float EaseInQuint(float x)
{
    return x * x * x * x * x;
}

float EaseOutQuint(float x)
{
    return 1.0 - pow(1.0 - x, 5.0);
}

float EaseInOutQuint(float x)
{
    return x < 0.5 ? 16.0 * x * x * x * x * x : 1.0 - pow(-2.0 * x + 2.0, 5.0) / 2.0;
}

float EaseInExpo(float x)
{
    return (x == 0) ? 0 : pow(2.0, 10.0 * x - 10.0);
}

float EaseOutExpo(float x)
{
    return (x == 1.0) ? 1.0 : 1.0 - pow(2.0, -10.0 * x);
}

float EaseInOutExpo(float x)
{
    return (x == 0) ? 0 : (x == 1) ? 1.0 : x < 0.5 ? pow(2.0, 20.0 * x - 10.0) / 2.0 : (2.0 - pow(2.0, -20.0 * x + 10.0)) / 2.0;
}

float EaseInCirc(float x)
{
    return 1.0 - sqrt(1.0 - pow(x, 2.0));
}

float EaseOutCirc(float x)
{
    return sqrt(1.0 - pow(x - 1.0, 2.0));
}

float EaseInOutCirc(float x)
{
    return x < 0.5 ? (1.0 - sqrt(1.0 - pow(2.0 * x, 2.0))) / 2.0 : (sqrt(1.0 - pow(-2.0 * x + 2.0, 2.0)) + 1.0) / 2.0;
}

float EaseInBack(float x, float c1 = 1.70158)
{
    float c3 = c1 + 1.0;
    return c3 * x * x * x - c1 * x * x;
}

float EaseOutBack(float x, float c1 = 1.70158)
{
    float c3 = c1 + 1.0;
    return 1.0 + c3 * pow(x - 1.0, 3.0) + c1 * pow(x - 1.0, 2.0);
}

float EaseInOutBack(float x, float c1 = 1.70158)
{
    float c2 = c1 * 1.525;

    return x < 0.5 ? (pow(2.0 * x, 2.0) * ((c2 + 1.0) * 2.0 * x - c2)) / 2.0 : (pow(2.0 * x - 2.0, 2.0) * ((c2 + 1.0) * (x * 2.0 - 2.0) + c2) + 2.0) / 2.0;
}

float EaseInElastic(float x, float c4 = (2.0 * PI) / 3.0)
{
    return (x == 0) ? 0 : (x == 1) ? 1.0 : -pow(2.0, 10.0 * x - 10.0) * sin((x * 10.0 - 10.75) * c4);
}

float EaseOutElastic(float x, float c4 = (2.0 * PI) / 3.0)
{
    return (x == 0) ? 0 : (x == 1) ? 1 : pow(2.0, -10.0 * x) * sin((x * 10.0 - 0.75) * c4) + 1;
}

float EaseInOutElastic(float x, float c5 = (2.0 * PI) / 4.5)
{
    return (x == 0) ? 0 : (x == 1) ? 1 : x < 0.5 ? -(pow(2.0, 20.0 * x - 10.0) * sin((20.0 * x - 11.125) * c5)) / 2.0 : (pow(2.0, -20.0 * x + 10.0) * sin((20.0 * x - 11.125) * c5)) / 2.0 + 1.0;
}

float EaseOutBounce(float x, float n1 = 7.5625, float d1 = 2.75)
{
    if (x < 1.0 / d1)
    {
        return n1 * x * x;
    }
    else if (x < 2.0 / d1)
    {
        return n1 * (x -= 1.5 / d1) * x + 0.75;
    }
    else if (x < 2.5 / d1)
    {
        return n1 * (x -= 2.25 / d1) * x + 0.9375;
    }
    else
    {
        return n1 * (x -= 2.625 / d1) * x + 0.984375;
    }
}

float EaseInBounce(float x)
{
    return 1.0 - EaseOutBounce(1.0 - x);
}

float EaseInOutBounce(float x)
{
    return x < 0.5 ? (1.0 - EaseOutBounce(1.0 - 2.0 * x)) / 2.0 : (1.0 + EaseOutBounce(2.0 * x - 1.0)) / 2.0;
}

float GetCurveByIndex(int curveType, float p)
{
    switch (curveType)
    {
        case EASE_IN_SINE:
            return EaseInSine(p);
        case EASE_OUT_SINE:
            return EaseOutSine(p);
        case EASE_IN_OUT_SINE:
            return EaseInOutSine(p);
        case EASE_IN_QUAD:
            return EaseInQuad(p);
        case EASE_OUT_QUAD:
            return EaseOutQuad(p);
        case EASE_IN_OUT_QUAD:
            return EaseInOutQuad(p);
        case EASE_IN_CUBIC:
            return EaseInCubic(p);
        case EASE_OUT_CUBIC:
            return EaseOutCubic(p);
        case EASE_IN_OUT_CUBIC:
            return EaseInOutCubic(p);
        case EASE_IN_QUART:
            return EaseInQuart(p);
        case EASE_OUT_QUART:
            return EaseOutQuart(p);
        case EASE_IN_OUT_QUART:
            return EaseInOutQuart(p);
        case EASE_IN_QUINT:
            return EaseInQuint(p);
        case EASE_OUT_QUINT:
            return EaseOutQuint(p);
        case EASE_IN_OUT_QUINT:
            return EaseInOutQuint(p);
        case EASE_IN_EXPO:
            return EaseInExpo(p);
        case EASE_OUT_EXPO:
            return EaseOutExpo(p);
        case EASE_IN_OUT_EXPO:
            return EaseInOutExpo(p);
        case EASE_IN_CIRC:
            return EaseInCirc(p);
        case EASE_OUT_CIRC:
            return EaseOutCirc(p);
        case EASE_IN_OUT_CIRC:
            return EaseInOutCirc(p);
        case EASE_IN_BACK:
            return EaseInBack(p);
        case EASE_OUT_BACK:
            return EaseOutBack(p);
        case EASE_IN_OUT_BACK:
            return EaseInOutBack(p);
        case EASE_IN_ELASTIC:
            return EaseInElastic(p);
        case EASE_OUT_ELASTIC:
            return EaseOutElastic(p);
        case EASE_IN_OUT_ELASTIC:
            return EaseInOutElastic(p);
        case EASE_IN_BOUNCE:
            return EaseInBounce(p);
        case EASE_OUT_BOUNCE:
            return EaseOutBounce(p);
        case EASE_IN_OUT_BOUNCE:
            return EaseInOutBounce(p);
        default:
            return 1.0;
            break;
    }
}