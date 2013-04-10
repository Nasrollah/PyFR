# -*- coding: utf-8 -*-

<%namespace name='util' module='pyfr.backends.c.makoutil' />
<%include file='common.h.mak' />

static NOINLINE void
gradcoru_aux(size_t neles,
             ${util.arr_args('jm', [ndims, ndims], const=True)},
             ${util.arr_args('tgrad_u', [ndims, nvars])})
{
    ${util.arr_align('jm', [ndims, ndims])};
    ${util.arr_align('tgrad_u', [ndims, nvars])};

    for (size_t eidx = 0; eidx < neles; eidx++)
    {
        // Dereference the (transformed) gradient
    % for i, j in util.ndrange(ndims, nvars):
        ${dtype} gu${i}${j} = tgrad_u${i}${j}[eidx];
    % endfor

        // Untransform and store
    % for i, j in util.ndrange(ndims, nvars):
        tgrad_u${i}${j}[eidx] = ${' + '.join('jm{0}{2}[eidx]*gu{2}{1}'
                                             .format(i, j, k)
                                             for k in range(ndims))};
    % endfor
    }
}

void
gradcoru(size_t nfpts, size_t neles,
         const ${dtype} *jmats, ${dtype} *tgrad_u,
         size_t ldj, size_t ldg, size_t lsdj, size_t lsdg)
{
    #pragma omp parallel for
    for (size_t fidx = 0; fidx < nfpts; fidx++)
    {
        gradcoru_aux(neles,
                     ${', '.join('jmats + fidx*ldj + {}*lsdj'.format(i)
                                 for i in range(ndims**2))},
                     ${', '.join('tgrad_u + ({}*nfpts + fidx)*ldg + {}*lsdg'
                                 .format(i, j)
                                 for i, j in util.ndrange(ndims, nvars))});
    }
}