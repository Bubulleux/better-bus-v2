import 'package:better_bus_core/core.dart';
import 'package:flutter/material.dart';

class DirectionSelector extends StatefulWidget {
  const DirectionSelector(this.line,
      {required this.selected, required this.onChanged, super.key});

  final BusLine line;
  final Set<Direction> selected;
  final void Function(Set<Direction> value) onChanged;

  @override
  State<DirectionSelector> createState() => _DirectionSelectorState();
}

class _DirectionSelectorState extends State<DirectionSelector> {
  void directionArrowClicked(int dirId) {
    final direction =
        widget.line.directions.where((e) => e.directionId == dirId).toSet();
    if (widget.selected.containsAll(direction)) {
      widget.onChanged(widget.selected.difference(direction));
    } else {
      widget.onChanged({...widget.selected, ...direction});
    }
  }

  Widget _buildArrow(int direction, bool? state) {
    IconData icon = direction == 1 ? Icons.arrow_back : Icons.arrow_forward;
    Color color = Theme.of(context).primaryColor;
    Color grey = Colors.grey;
    return InkWell(
      onTap: () => directionArrowClicked(direction),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.all(5),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: state == true ? color : grey,
            width: 3,
          ),
        ),
        child: Icon(
          icon,
          color: state != false ? color : grey,
        ),
      ),
    );
  }

  Widget _buildDirections({required int dirId, required Widget child}) {
    assert(dirId == 1 || dirId == 0);
    final directions =
        widget.line.directions.where((e) => e.directionId == dirId).toSet();
    bool? arrowState = widget.selected.containsAll(directions);
    if (!arrowState && widget.selected.intersection(directions).isNotEmpty)
      arrowState = null;

    final out = [
      _buildArrow(dirId, arrowState),
      const SizedBox(
        width: 5,
      ),
      child,
    ];
    return Row(
      mainAxisAlignment:
          dirId == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: dirId == 0 ? out.reversed.toList() : out,
    );
  }

  void directionClicked(Direction direction) {
    final out = widget.selected.toSet();
    if (widget.selected.contains(direction)) {
      out.remove(direction);
    } else {
      out.add(direction);
    }
    widget.onChanged(out);
  }

  Widget _buildOneDirection(Direction direction) {
    final out = [
      Checkbox(
        value: widget.selected.contains(direction),
        onChanged: (value) => directionClicked(direction),
        visualDensity: const VisualDensity(horizontal: -3, vertical: -4),
      ),
      Text(direction.destination)
    ];

    // Remove Checkbox if their is only one direction.
    if (widget.line.directions
            .where((e) => e.directionId == direction.directionId)
            .length ==
        1) {
      out.removeAt(0);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => directionClicked(direction),
        child: Row(
          children: direction.directionId == 0 ? out.reversed.toList() : out,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Direction> top =
        widget.line.directions.where((e) => e.directionId == 1).toList();
    List<Direction> bot =
        widget.line.directions.where((e) => e.directionId == 0).toList();
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor.withAlpha(150),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...top.isNotEmpty
              ? [
                  _buildDirections(
                    dirId: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: top.map((e) => _buildOneDirection(e)).toList(),
                    ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                ]
              : [],
          _buildDirections(
            dirId: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bot.map((e) => _buildOneDirection(e)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
