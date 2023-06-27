import 'package:flutter/widgets.dart';

import '../drip_core/drip_core.dart';

typedef DCreate<D extends Drip> = D Function(BuildContext context);

typedef DBuilder<D extends Drip<DState>, DState> = Widget Function(D drip, DState state);

typedef DListener<D extends Drip, DState> = void Function(D drip, DState state);

typedef Selector<DState, T> = T Function(DState state);

typedef SBuilder<D extends Drip, SelectedState> = Widget Function(D drip, SelectedState data);
